import { useState } from "react";
import { Choice, PALETTE, Panel, Stat, Verdict } from "./controls";
import { Console } from "./inf7-noyau";

/** Informatique Terminale C et D — chapitre 11 : réaliser un petit réseau local. */

function masqueValide(m: string) {
  return ["255.0.0.0", "255.255.0.0", "255.255.255.0"].includes(m);
}

function partieReseau(ip: string, masque: string) {
  const a = ip.split(".").map(Number);
  const b = masque.split(".").map(Number);
  if (a.length !== 4 || b.length !== 4) return "";
  return a.map((x, i) => x & (b[i] ?? 0)).join(".");
}

function ipValide(ip: string) {
  const p = ip.split(".");
  if (p.length !== 4) return false;
  return p.every((x) => /^\d{1,3}$/.test(x) && Number(x) >= 0 && Number(x) <= 255);
}

/* ------------------------------------------------------------------ */
/* Chapitre 11 — La fenêtre des propriétés TCP/IPv4                    */
/* ------------------------------------------------------------------ */

const DEFAUTS = [
  { value: "aucun", label: "Configuration correcte" },
  { value: "double", label: "Adresse en double" },
  { value: "masque", label: "Masque différent" },
  { value: "passerelle", label: "Passerelle absente" },
] as const;

export function CarteReseau() {
  const [ip, setIp] = useState("192.168.1.10");
  const [masque, setMasque] = useState("255.255.255.0");
  const [passerelle, setPasserelle] = useState("192.168.1.1");
  const [dns, setDns] = useState("8.8.8.8");
  const [defaut, setDefaut] = useState<string>("aucun");
  const [teste, setTeste] = useState(false);

  // Le réseau de référence : les voisins sont en 192.168.1.x, la passerelle en 192.168.1.1.
  const refReseau = "192.168.1.0";
  const refMasque = "255.255.255.0";

  const ipOk = ipValide(ip);
  const masqueOk = masqueValide(masque);
  const monReseau = ipOk && masqueOk ? partieReseau(ip, masque) : "";
  const passerelleJoignable =
    ipValide(passerelle) && masqueOk && partieReseau(passerelle, masque) === monReseau;

  const doublon = defaut === "double";
  const masqueDiff = defaut === "masque" || (masqueOk && masque !== refMasque);
  const sansPasserelle = defaut === "passerelle" || passerelle.trim() === "";

  const voitVoisins = ipOk && masqueOk && monReseau === refReseau && !masqueDiff && !doublon;
  const sortInternet = voitVoisins && !sansPasserelle && passerelleJoignable;
  const atteintNom = sortInternet && ipValide(dns);

  const lignes: string[] = [];
  if (teste) {
    lignes.push("> ping 192.168.1.20   (un poste voisin)");
    lignes.push(
      voitVoisins
        ? "Réponse de 192.168.1.20 : octets=32 temps<1 ms"
        : doublon
          ? "Conflit d'adresse IP détecté sur le réseau — réponse incohérente"
          : "Hôte de destination inaccessible.",
    );
    lignes.push("> ping 192.168.1.1   (la passerelle)");
    lignes.push(
      sansPasserelle
        ? "Aucune passerelle configurée : la requête ne sort pas du poste."
        : passerelleJoignable && voitVoisins
          ? "Réponse de 192.168.1.1 : octets=32 temps=1 ms"
          : "Hôte de destination inaccessible.",
    );
    lignes.push("> ping 8.8.8.8   (une machine sur Internet)");
    lignes.push(
      sortInternet
        ? "Réponse de 8.8.8.8 : octets=32 temps=42 ms"
        : "Délai d'attente de la demande dépassé.",
    );
    lignes.push("> ping www.minesec.cm   (par son nom)");
    lignes.push(
      atteintNom
        ? "Réponse de 41.202.219.4 : octets=32 temps=58 ms"
        : sortInternet
          ? "La requête ping n'a pas pu trouver l'hôte. Vérifiez le nom."
          : "Délai d'attente de la demande dépassé.",
    );
  }

  const champ = (label: string, v: string, set: (s: string) => void, ok: boolean) => (
    <label className="block space-y-0.5">
      <span className="text-[11px] font-medium text-muted-foreground">{label}</span>
      <input
        value={v}
        onChange={(e) => set(e.target.value)}
        className={
          ok
            ? "w-full rounded border border-border bg-background px-2 py-1 font-mono text-xs"
            : "w-full rounded border-2 border-rose-500 bg-rose-500/10 px-2 py-1 font-mono text-xs"
        }
      />
    </label>
  );

  return (
    <div className="space-y-3">
      <div className="rounded-lg border-2 border-slate-400 bg-secondary/20 p-3">
        <p className="mb-2 text-xs font-semibold">
          Propriétés de : Protocole Internet version 4 (TCP/IPv4)
        </p>
        <div className="space-y-2">
          {champ("Adresse IP", ip, setIp, ipOk)}
          {champ("Masque de sous-réseau", masque, setMasque, masqueOk)}
          {champ(
            "Passerelle par défaut",
            passerelle,
            setPasserelle,
            passerelle === "" || ipValide(passerelle),
          )}
          {champ("Serveur DNS préféré", dns, setDns, dns === "" || ipValide(dns))}
        </div>
      </div>

      <Choice<string>
        label="Introduire volontairement un défaut"
        value={defaut}
        options={DEFAUTS.map((d) => ({ value: d.value, label: d.label }))}
        onChange={(v) => {
          setDefaut(v);
          setTeste(false);
          if (v === "aucun") {
            setIp("192.168.1.10");
            setMasque("255.255.255.0");
            setPasserelle("192.168.1.1");
          }
          if (v === "double") setIp("192.168.1.20");
          if (v === "masque") setMasque("255.255.0.0");
          if (v === "passerelle") setPasserelle("");
        }}
      />

      <button
        type="button"
        onClick={() => setTeste(true)}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        Tester la configuration
      </button>

      {teste ? (
        <>
          <Console lignes={lignes} />
          <Panel>
            <Stat
              label="Voit ses voisins"
              value={voitVoisins ? "oui" : "non"}
              color={voitVoisins ? PALETTE.green : PALETTE.red}
            />
            <Stat
              label="Sort vers Internet"
              value={sortInternet ? "oui" : "non"}
              color={sortInternet ? PALETTE.green : PALETTE.red}
            />
          </Panel>
          <Panel>
            <Stat
              label="Atteint un site par son nom"
              value={atteintNom ? "oui" : "non"}
              color={atteintNom ? PALETTE.green : PALETTE.red}
            />
            <Stat label="Réseau du poste" value={monReseau || "—"} />
          </Panel>

          {doublon ? (
            <Verdict tone="bad">
              Deux machines portent la même adresse. Windows affiche « Conflit d&apos;adresse IP »
              et les deux postes deviennent inutilisables de façon erratique : les réponses partent
              parfois à l&apos;une, parfois à l&apos;autre. Une adresse IP est{" "}
              <strong>unique sur un réseau</strong>, c&apos;est la règle absolue.
            </Verdict>
          ) : masqueDiff ? (
            <Verdict tone="bad">
              Le masque est différent de celui des voisins : ce poste croit appartenir au réseau{" "}
              <span className="font-mono">{monReseau}</span> quand les autres sont sur{" "}
              <span className="font-mono">{refReseau}</span>. L&apos;adresse est pourtant correcte —
              et c&apos;est ce qui rend l&apos;erreur si difficile à voir. Le masque doit être{" "}
              <strong>le même sur toutes les machines du réseau</strong>.
            </Verdict>
          ) : sansPasserelle ? (
            <Verdict tone="warn">
              Sans passerelle, le poste parle parfaitement à ses voisins — regarde le premier ping —
              mais ne sort pas du réseau local. C&apos;est le symptôme exact : « le réseau marche,
              mais pas Internet ». La passerelle est la porte de sortie.
            </Verdict>
          ) : atteintNom ? (
            <Verdict tone="ok">
              Les quatre tests passent. Et remarque l&apos;ordre : voisins, puis passerelle, puis
              Internet par adresse, puis Internet par nom.{" "}
              <strong>La première ligne qui échoue désigne la panne</strong> — c&apos;est toute la
              méthode du diagnostic réseau.
            </Verdict>
          ) : (
            <Verdict tone="warn">
              Le ping par adresse passe mais le ping par nom échoue : le réseau fonctionne,
              c&apos;est le <strong>DNS</strong> qui ne répond pas. Vérifie le serveur DNS préféré.
            </Verdict>
          )}
        </>
      ) : (
        <Verdict tone="warn">
          Les quatre champs sont ceux de la vraie fenêtre de Windows. Remplis-les, puis teste.
          Essaie ensuite les trois défauts classiques : tu verras que chacun casse une chose
          différente, et que c&apos;est précisément ce qui permet de le reconnaître.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 11 — Monter le réseau de trois postes                      */
/* ------------------------------------------------------------------ */

type Poste = { nom: string; ip: string; masque: string; cable: boolean };

export function MonterReseau() {
  const [postes, setPostes] = useState<Poste[]>([
    { nom: "PC1", ip: "", masque: "", cable: false },
    { nom: "PC2", ip: "", masque: "", cable: false },
    { nom: "PC3", ip: "", masque: "", cable: false },
  ]);
  const [switchPresent, setSwitchPresent] = useState(true);
  const [typeCable, setTypeCable] = useState<"droit" | "croise">("droit");
  const [teste, setTeste] = useState(false);

  const maj = (i: number, champ: keyof Poste, v: string | boolean) => {
    setPostes((p) => p.map((x, k) => (k === i ? { ...x, [champ]: v } : x)));
    setTeste(false);
  };

  const cables = postes.filter((p) => p.cable).length;
  const configures = postes.filter((p) => ipValide(p.ip) && masqueValide(p.masque)).length;

  const reseaux = postes
    .filter((p) => ipValide(p.ip) && masqueValide(p.masque))
    .map((p) => partieReseau(p.ip, p.masque));
  const ips = postes.filter((p) => ipValide(p.ip)).map((p) => p.ip);

  const doublon = new Set(ips).size !== ips.length;
  const reseauxDifferents = new Set(reseaux).size > 1;
  const masques = new Set(postes.filter((p) => masqueValide(p.masque)).map((p) => p.masque));
  const masquesDifferents = masques.size > 1;

  // Deux postes sans commutateur exigent un câble croisé.
  const deuxSansSwitch = !switchPresent && cables === 2;
  const cableIncorrect = deuxSansSwitch && typeCable === "droit";
  const troisSansSwitch = !switchPresent && cables > 2;

  const marche =
    cables === 3 &&
    configures === 3 &&
    !doublon &&
    !reseauxDifferents &&
    !masquesDifferents &&
    switchPresent;

  const remplir = () => {
    setPostes([
      { nom: "PC1", ip: "192.168.1.1", masque: "255.255.255.0", cable: true },
      { nom: "PC2", ip: "192.168.1.2", masque: "255.255.255.0", cable: true },
      { nom: "PC3", ip: "192.168.1.3", masque: "255.255.255.0", cable: true },
    ]);
    setSwitchPresent(true);
    setTeste(false);
  };

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap gap-1.5">
        <button
          type="button"
          onClick={() => {
            setSwitchPresent((v) => !v);
            setTeste(false);
          }}
          className={
            switchPresent
              ? "rounded-lg border border-emerald-500/50 bg-emerald-500/10 px-2.5 py-1.5 text-xs font-medium text-emerald-700"
              : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground"
          }
        >
          {switchPresent ? "Commutateur branché" : "Pas de commutateur"}
        </button>
        <button
          type="button"
          onClick={remplir}
          className="rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Plan d&apos;adressage correct
        </button>
      </div>

      {!switchPresent ? (
        <Choice<"droit" | "croise">
          label="Câble entre les deux postes"
          value={typeCable}
          options={[
            { value: "droit", label: "Câble droit" },
            { value: "croise", label: "Câble croisé" },
          ]}
          onChange={(v) => {
            setTypeCable(v);
            setTeste(false);
          }}
        />
      ) : null}

      <div className="space-y-2">
        {postes.map((p, i) => (
          <div
            key={p.nom}
            className="space-y-1 rounded-lg border border-border bg-background p-2.5"
          >
            <div className="flex items-center justify-between gap-2">
              <p className="text-xs font-semibold">{p.nom}</p>
              <button
                type="button"
                onClick={() => maj(i, "cable", !p.cable)}
                className={
                  p.cable
                    ? "rounded border border-emerald-500/50 bg-emerald-500/10 px-2 py-0.5 text-[10px] font-medium text-emerald-700"
                    : "rounded border border-border bg-background px-2 py-0.5 text-[10px] text-muted-foreground"
                }
              >
                {p.cable ? "câblé" : "débranché"}
              </button>
            </div>
            <div className="grid gap-1.5 sm:grid-cols-2">
              <input
                value={p.ip}
                onChange={(e) => maj(i, "ip", e.target.value)}
                placeholder="adresse IP"
                className={
                  p.ip === "" || ipValide(p.ip)
                    ? "rounded border border-border bg-background px-2 py-1 font-mono text-xs"
                    : "rounded border-2 border-rose-500 bg-rose-500/10 px-2 py-1 font-mono text-xs"
                }
              />
              <input
                value={p.masque}
                onChange={(e) => maj(i, "masque", e.target.value)}
                placeholder="masque"
                className={
                  p.masque === "" || masqueValide(p.masque)
                    ? "rounded border border-border bg-background px-2 py-1 font-mono text-xs"
                    : "rounded border-2 border-rose-500 bg-rose-500/10 px-2 py-1 font-mono text-xs"
                }
              />
            </div>
            {ipValide(p.ip) && masqueValide(p.masque) ? (
              <p className="font-mono text-[10px] text-muted-foreground">
                réseau : {partieReseau(p.ip, p.masque)}
              </p>
            ) : null}
          </div>
        ))}
      </div>

      <Panel>
        <Stat label="Postes câblés" value={`${cables} / 3`} />
        <Stat label="Postes configurés" value={`${configures} / 3`} />
      </Panel>

      <button
        type="button"
        onClick={() => setTeste(true)}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        Tester le réseau
      </button>

      {!teste ? (
        <Verdict tone="warn">
          Trois étapes, dans cet ordre : <strong>câbler</strong>, <strong>adresser</strong>,{" "}
          <strong>tester</strong>. Inverse-les et tu perdras du temps à chercher une panne logique
          dans un câble débranché.
        </Verdict>
      ) : cableIncorrect ? (
        <Verdict tone="bad">
          Deux postes reliés directement, sans commutateur, exigent un <strong>câble croisé</strong>
          : c&apos;est lui qui inverse émission et réception. Avec un câble droit, les deux machines
          émettent sur la même paire et aucune n&apos;écoute. Les cartes réseau récentes corrigent
          cela toutes seules, mais la question d&apos;examen attend le câble croisé.
        </Verdict>
      ) : troisSansSwitch ? (
        <Verdict tone="bad">
          Trois machines ne peuvent pas être reliées deux à deux sans équipement : une carte réseau
          n&apos;a qu&apos;un seul port. Il faut un <strong>commutateur</strong>.
        </Verdict>
      ) : doublon ? (
        <Verdict tone="bad">
          Deux postes portent la même adresse IP. Le réseau refuse ce plan d&apos;adressage : une
          adresse est <strong>unique</strong>. Change l&apos;une des deux.
        </Verdict>
      ) : masquesDifferents ? (
        <Verdict tone="bad">
          Les masques ne sont pas identiques sur toutes les machines. Le masque définit où
          s&apos;arrête le réseau : s&apos;il diffère, les postes ne s&apos;accordent même pas sur
          le réseau auquel ils appartiennent.
        </Verdict>
      ) : reseauxDifferents ? (
        <Verdict tone="bad">
          Les parties réseau diffèrent : {Array.from(new Set(reseaux)).join(" et ")}. Ces postes
          sont sur deux réseaux distincts et ne se verront pas, même reliés au même commutateur. Il
          faudrait un routeur — ou, plus simplement ici, le même préfixe pour les trois.
        </Verdict>
      ) : marche ? (
        <Verdict tone="ok">
          Le réseau fonctionne. Les trois postes sont câblés au commutateur, portent des adresses{" "}
          <strong>uniques</strong> de la <strong>même partie réseau</strong>, avec le{" "}
          <strong>même masque</strong>. Ce sont les trois conditions, et il n&apos;y en a pas
          d&apos;autre pour un réseau local sans sortie.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Il manque encore quelque chose : {cables < 3 ? "des câbles" : "des adresses"}. Complète,
          puis reteste.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 11 — L'invite de commandes                                 */
/* ------------------------------------------------------------------ */

const MACHINES = [
  {
    id: "m0",
    label: "Machine saine",
    ipconfig: [
      "   Adresse IPv4. . . . . . . . : 192.168.1.10",
      "   Masque . . . . . . . . . . . : 255.255.255.0",
      "   Passerelle par défaut. . . . : 192.168.1.1",
    ],
    echoue: "aucun",
    diag: "Tout répond. Rien à réparer.",
  },
  {
    id: "m1",
    label: "Carte désactivée",
    ipconfig: ["   Carte Ethernet : média déconnecté"],
    echoue: "local",
    diag: "Le ping 127.0.0.1 passe — la pile TCP/IP du poste est saine — mais le ping de la propre adresse échoue, et pour cause : la carte n'a plus d'adresse. Réactive-la dans le gestionnaire de périphériques.",
  },
  {
    id: "m2",
    label: "Adresse automatique privée",
    ipconfig: [
      "   Adresse IPv4. . . . . . . . : 169.254.44.17",
      "   Masque . . . . . . . . . . . : 255.255.0.0",
      "   Passerelle par défaut. . . . :",
    ],
    echoue: "voisin",
    diag: "Une adresse en 169.254.x.x est l'adresse que Windows s'attribue tout seul quand AUCUN serveur DHCP ne lui répond. Le symptôme est donc celui d'un câble débranché, d'un commutateur éteint, ou d'un DHCP en panne. C'est l'indice le plus utile de tout ipconfig.",
  },
  {
    id: "m3",
    label: "Adresse en double",
    ipconfig: [
      "   Adresse IPv4. . . . . . . . : 192.168.1.20 (en conflit)",
      "   Masque . . . . . . . . . . . : 255.255.255.0",
      "   Passerelle par défaut. . . . : 192.168.1.1",
    ],
    echoue: "voisin",
    diag: "Windows signale le conflit entre parenthèses. Deux machines se disputent la même adresse, et les réponses partent au hasard à l'une ou à l'autre.",
  },
  {
    id: "m4",
    label: "Passerelle absente",
    ipconfig: [
      "   Adresse IPv4. . . . . . . . : 192.168.1.10",
      "   Masque . . . . . . . . . . . : 255.255.255.0",
      "   Passerelle par défaut. . . . :",
    ],
    echoue: "internet",
    diag: "Les voisins répondent, Internet non : la ligne « Passerelle par défaut » est vide. Le poste ne sait pas par où sortir.",
  },
  {
    id: "m5",
    label: "DNS muet",
    ipconfig: [
      "   Adresse IPv4. . . . . . . . : 192.168.1.10",
      "   Masque . . . . . . . . . . . : 255.255.255.0",
      "   Passerelle par défaut. . . . : 192.168.1.1",
      "   Serveurs DNS . . . . . . . . : 10.0.0.99",
    ],
    echoue: "nom",
    diag: "Le ping par adresse passe, le ping par nom échoue : seule la résolution de noms est en cause. Le serveur DNS configuré ne répond pas. C'est le symptôme qu'on prend pour « Internet est coupé » alors que tout fonctionne sauf la traduction des noms.",
  },
] as const;

const ETAPES = [
  { cle: "pile", cmd: "ping 127.0.0.1", quoi: "la pile TCP/IP du poste lui-même" },
  { cle: "local", cmd: "ping 192.168.1.10", quoi: "sa propre adresse, donc sa carte réseau" },
  { cle: "voisin", cmd: "ping 192.168.1.20", quoi: "un voisin, donc le câble et le commutateur" },
  { cle: "passerelle", cmd: "ping 192.168.1.1", quoi: "la passerelle, donc la porte de sortie" },
  { cle: "internet", cmd: "ping 8.8.8.8", quoi: "Internet par adresse" },
  { cle: "nom", cmd: "ping www.minesec.cm", quoi: "Internet par nom, donc le DNS" },
] as const;

const ORDRE = ["pile", "local", "voisin", "passerelle", "internet", "nom"] as const;

export function CommandesReseau() {
  const [m, setM] = useState(0);
  const [lignes, setLignes] = useState<string[]>([]);
  const [rep, setRep] = useState<string | null>(null);

  const mac = MACHINES[m] ?? MACHINES[0];
  const rangEchec = ORDRE.indexOf(mac.echoue as (typeof ORDRE)[number]);

  const ajouter = (s: string[]) => setLignes((v) => [...v, ...s]);

  const ipconfig = (tout: boolean) => {
    ajouter([
      `> ipconfig${tout ? " /all" : ""}`,
      "Configuration IP de Windows",
      "",
      ...(tout
        ? [
            "   Nom de l'hôte . . . . . . . : POSTE-07",
            "   Adresse physique. . . . . . : 00-1A-2B-3C-4D-5E",
            ...mac.ipconfig,
          ]
        : mac.ipconfig),
      "",
    ]);
  };

  const pinger = (cle: string, cmd: string) => {
    const rang = ORDRE.indexOf(cle as (typeof ORDRE)[number]);
    const echoue = rangEchec >= 0 && rang >= rangEchec;
    ajouter([
      `> ${cmd}`,
      echoue
        ? cle === "nom"
          ? "La requête ping n'a pas pu trouver l'hôte. Vérifiez le nom et réessayez."
          : "Hôte de destination inaccessible."
        : `Réponse de ${cmd.replace("ping ", "")} : octets=32 temps<1 ms TTL=64`,
      "",
    ]);
  };

  const juste = rep === mac.echoue;

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap gap-1.5">
        {MACHINES.map((x, k) => (
          <button
            key={x.id}
            type="button"
            onClick={() => {
              setM(k);
              setLignes([]);
              setRep(null);
            }}
            className={
              k === m
                ? "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
                : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
            }
          >
            {x.label}
          </button>
        ))}
      </div>

      <div className="flex flex-wrap gap-1.5">
        <button
          type="button"
          onClick={() => ipconfig(false)}
          className="rounded-lg border border-border bg-background px-2.5 py-1 font-mono text-[11px] text-muted-foreground hover:bg-secondary/60"
        >
          ipconfig
        </button>
        <button
          type="button"
          onClick={() => ipconfig(true)}
          className="rounded-lg border border-border bg-background px-2.5 py-1 font-mono text-[11px] text-muted-foreground hover:bg-secondary/60"
        >
          ipconfig /all
        </button>
        {ETAPES.map((e) => (
          <button
            key={e.cle}
            type="button"
            onClick={() => pinger(e.cle, e.cmd)}
            title={e.quoi}
            className="rounded-lg border border-border bg-background px-2.5 py-1 font-mono text-[11px] text-muted-foreground hover:bg-secondary/60"
          >
            {e.cmd}
          </button>
        ))}
        <button
          type="button"
          onClick={() => setLignes([])}
          className="rounded-lg border border-border bg-background px-2.5 py-1 text-[11px] font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Effacer
        </button>
      </div>

      <Console lignes={lignes} titre="Invite de commandes" />

      <div className="space-y-1 rounded-lg border border-border bg-background p-3">
        <p className="text-xs font-semibold">La chaîne de diagnostic, dans l&apos;ordre</p>
        {ETAPES.map((e, k) => (
          <p key={e.cle} className="font-mono text-[10px] text-muted-foreground">
            {k + 1}. {e.cmd} — <span className="font-sans">{e.quoi}</span>
          </p>
        ))}
        <p className="mt-1 text-[11px] text-muted-foreground">
          <strong className="text-foreground">
            La première ligne qui échoue désigne la panne.
          </strong>{" "}
          Tout ce qui est en amont fonctionne, tout ce qui est en aval est une conséquence.
        </p>
      </div>

      <Choice<string>
        label="Où la chaîne se casse-t-elle ?"
        value={rep ?? ""}
        options={[
          { value: "aucun", label: "Nulle part" },
          ...ETAPES.map((e) => ({ value: e.cle, label: e.cmd.replace("ping ", "") })),
        ]}
        onChange={setRep}
      />

      {rep === null ? (
        <Verdict tone="warn">
          Commence par <span className="font-mono">ipconfig</span> : il te donne l&apos;adresse, le
          masque et la passerelle, et c&apos;est souvent lui seul qui révèle la panne. Puis remonte
          la chaîne des ping.
        </Verdict>
      ) : juste ? (
        <Verdict tone="ok">{mac.diag}</Verdict>
      ) : (
        <Verdict tone="bad">
          Non. La chaîne casse à{" "}
          <span className="font-mono">
            {mac.echoue === "aucun"
              ? "aucune étape"
              : (ETAPES.find((e) => e.cle === mac.echoue)?.cmd ?? "")}
          </span>
          . {mac.diag}
        </Verdict>
      )}
    </div>
  );
}
