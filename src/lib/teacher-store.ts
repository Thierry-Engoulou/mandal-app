import { useSyncExternalStore } from "react";

const KEY = "mandal.enseignant.etablissement";

let selected: string | null = null;
let hydrated = false;
const listeners = new Set<() => void>();

function emit() {
  listeners.forEach((l) => l());
}

function hydrate() {
  if (hydrated || typeof window === "undefined") return;
  hydrated = true;
  const stored = window.localStorage.getItem(KEY);
  if (stored) {
    selected = stored;
    emit();
  }
}

export function setSelectedSchoolId(id: string | null) {
  selected = id;
  if (typeof window !== "undefined") {
    if (id) window.localStorage.setItem(KEY, id);
    else window.localStorage.removeItem(KEY);
  }
  emit();
}

function subscribe(listener: () => void) {
  hydrate();
  listeners.add(listener);
  return () => {
    listeners.delete(listener);
  };
}

export function useSelectedSchoolId() {
  return useSyncExternalStore(
    subscribe,
    () => selected,
    () => null,
  );
}
