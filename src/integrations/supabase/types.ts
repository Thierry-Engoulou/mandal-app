export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      badges: {
        Row: {
          created_at: string
          critere: string | null
          description: string | null
          icon_url: string | null
          id: string
          nom: string
        }
        Insert: {
          created_at?: string
          critere?: string | null
          description?: string | null
          icon_url?: string | null
          id?: string
          nom: string
        }
        Update: {
          created_at?: string
          critere?: string | null
          description?: string | null
          icon_url?: string | null
          id?: string
          nom?: string
        }
        Relationships: []
      }
      chapitres: {
        Row: {
          created_at: string
          id: string
          niveau: string | null
          ordre: number
          programme_id: string
          titre: string
        }
        Insert: {
          created_at?: string
          id?: string
          niveau?: string | null
          ordre?: number
          programme_id: string
          titre: string
        }
        Update: {
          created_at?: string
          id?: string
          niveau?: string | null
          ordre?: number
          programme_id?: string
          titre?: string
        }
        Relationships: [
          {
            foreignKeyName: "chapitres_programme_id_fkey"
            columns: ["programme_id"]
            isOneToOne: false
            referencedRelation: "programmes"
            referencedColumns: ["id"]
          },
        ]
      }
      class_membres: {
        Row: {
          class_id: string
          created_at: string
          eleve_id: string
          id: string
        }
        Insert: {
          class_id: string
          created_at?: string
          eleve_id: string
          id?: string
        }
        Update: {
          class_id?: string
          created_at?: string
          eleve_id?: string
          id?: string
        }
        Relationships: [
          {
            foreignKeyName: "class_membres_class_id_fkey"
            columns: ["class_id"]
            isOneToOne: false
            referencedRelation: "classes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "class_membres_eleve_id_fkey"
            columns: ["eleve_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      classes: {
        Row: {
          annee_scolaire: string | null
          created_at: string
          description: string | null
          effectif: number
          enseignant_id: string | null
          etablissement_id: string
          filiere: string | null
          id: string
          is_composite: boolean
          niveau: string | null
          nom: string
          updated_at: string
        }
        Insert: {
          annee_scolaire?: string | null
          created_at?: string
          description?: string | null
          effectif?: number
          enseignant_id?: string | null
          etablissement_id: string
          filiere?: string | null
          id?: string
          is_composite?: boolean
          niveau?: string | null
          nom: string
          updated_at?: string
        }
        Update: {
          annee_scolaire?: string | null
          created_at?: string
          description?: string | null
          effectif?: number
          enseignant_id?: string | null
          etablissement_id?: string
          filiere?: string | null
          id?: string
          is_composite?: boolean
          niveau?: string | null
          nom?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "classes_enseignant_id_fkey"
            columns: ["enseignant_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "classes_etablissement_id_fkey"
            columns: ["etablissement_id"]
            isOneToOne: false
            referencedRelation: "etablissements"
            referencedColumns: ["id"]
          },
        ]
      }
      concepts: {
        Row: {
          chapitre_id: string
          contenu_texte: string | null
          created_at: string
          duree_minutes: number | null
          id: string
          media_url: string | null
          ordre: number
          titre: string
          type_contenu: string
        }
        Insert: {
          chapitre_id: string
          contenu_texte?: string | null
          created_at?: string
          duree_minutes?: number | null
          id?: string
          media_url?: string | null
          ordre?: number
          titre: string
          type_contenu?: string
        }
        Update: {
          chapitre_id?: string
          contenu_texte?: string | null
          created_at?: string
          duree_minutes?: number | null
          id?: string
          media_url?: string | null
          ordre?: number
          titre?: string
          type_contenu?: string
        }
        Relationships: [
          {
            foreignKeyName: "concepts_chapitre_id_fkey"
            columns: ["chapitre_id"]
            isOneToOne: false
            referencedRelation: "chapitres"
            referencedColumns: ["id"]
          },
        ]
      }
      conversations: {
        Row: {
          created_at: string
          eleve_id: string
          enseignant_id: string | null
          id: string
          statut: string
          sujet: string
          type: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          eleve_id: string
          enseignant_id?: string | null
          id?: string
          statut?: string
          sujet: string
          type?: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          eleve_id?: string
          enseignant_id?: string | null
          id?: string
          statut?: string
          sujet?: string
          type?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "conversations_eleve_id_fkey"
            columns: ["eleve_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "conversations_enseignant_id_fkey"
            columns: ["enseignant_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      courses: {
        Row: {
          author_id: string
          content: string
          created_at: string
          id: string
          is_published: boolean
          level: Database["public"]["Enums"]["course_level"]
          pillar: Database["public"]["Enums"]["pillar"]
          title: string
          updated_at: string
        }
        Insert: {
          author_id: string
          content: string
          created_at?: string
          id?: string
          is_published?: boolean
          level?: Database["public"]["Enums"]["course_level"]
          pillar: Database["public"]["Enums"]["pillar"]
          title: string
          updated_at?: string
        }
        Update: {
          author_id?: string
          content?: string
          created_at?: string
          id?: string
          is_published?: boolean
          level?: Database["public"]["Enums"]["course_level"]
          pillar?: Database["public"]["Enums"]["pillar"]
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      eleve_badges: {
        Row: {
          badge_id: string
          date_obtention: string
          eleve_id: string
          id: string
        }
        Insert: {
          badge_id: string
          date_obtention?: string
          eleve_id: string
          id?: string
        }
        Update: {
          badge_id?: string
          date_obtention?: string
          eleve_id?: string
          id?: string
        }
        Relationships: [
          {
            foreignKeyName: "eleve_badges_badge_id_fkey"
            columns: ["badge_id"]
            isOneToOne: false
            referencedRelation: "badges"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eleve_badges_eleve_id_fkey"
            columns: ["eleve_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      etablissements: {
        Row: {
          created_at: string
          id: string
          logo_url: string | null
          nom: string
          systeme_educatif: string
          type: string | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          logo_url?: string | null
          nom: string
          systeme_educatif?: string
          type?: string | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          logo_url?: string | null
          nom?: string
          systeme_educatif?: string
          type?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      examens: {
        Row: {
          chapitre_id: string | null
          classe_id: string | null
          created_at: string
          created_by: string | null
          date_debut: string | null
          date_fin: string | null
          description: string | null
          deverrouille_si: string
          duree_minutes: number
          etablissement_id: string | null
          id: string
          mode_evaluation: string
          nb_questions: number
          programme_id: string | null
          statut: string
          titre: string
          updated_at: string
        }
        Insert: {
          chapitre_id?: string | null
          classe_id?: string | null
          created_at?: string
          created_by?: string | null
          date_debut?: string | null
          date_fin?: string | null
          description?: string | null
          deverrouille_si?: string
          duree_minutes?: number
          etablissement_id?: string | null
          id?: string
          mode_evaluation?: string
          nb_questions?: number
          programme_id?: string | null
          statut?: string
          titre: string
          updated_at?: string
        }
        Update: {
          chapitre_id?: string | null
          classe_id?: string | null
          created_at?: string
          created_by?: string | null
          date_debut?: string | null
          date_fin?: string | null
          description?: string | null
          deverrouille_si?: string
          duree_minutes?: number
          etablissement_id?: string | null
          id?: string
          mode_evaluation?: string
          nb_questions?: number
          programme_id?: string | null
          statut?: string
          titre?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "examens_chapitre_id_fkey"
            columns: ["chapitre_id"]
            isOneToOne: false
            referencedRelation: "chapitres"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "examens_classe_id_fkey"
            columns: ["classe_id"]
            isOneToOne: false
            referencedRelation: "classes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "examens_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "examens_etablissement_id_fkey"
            columns: ["etablissement_id"]
            isOneToOne: false
            referencedRelation: "etablissements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "examens_programme_id_fkey"
            columns: ["programme_id"]
            isOneToOne: false
            referencedRelation: "programmes"
            referencedColumns: ["id"]
          },
        ]
      }
      invitations_admin: {
        Row: {
          created_at: string
          created_by: string | null
          email: string
          etablissement_id: string
          expire_le: string
          id: string
          statut: string
          token: string
        }
        Insert: {
          created_at?: string
          created_by?: string | null
          email: string
          etablissement_id: string
          expire_le?: string
          id?: string
          statut?: string
          token?: string
        }
        Update: {
          created_at?: string
          created_by?: string | null
          email?: string
          etablissement_id?: string
          expire_le?: string
          id?: string
          statut?: string
          token?: string
        }
        Relationships: [
          {
            foreignKeyName: "invitations_admin_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "invitations_admin_etablissement_id_fkey"
            columns: ["etablissement_id"]
            isOneToOne: false
            referencedRelation: "etablissements"
            referencedColumns: ["id"]
          },
        ]
      }
      matieres: {
        Row: {
          couleur: string | null
          created_at: string
          id: string
          nom: string
        }
        Insert: {
          couleur?: string | null
          created_at?: string
          id?: string
          nom: string
        }
        Update: {
          couleur?: string | null
          created_at?: string
          id?: string
          nom?: string
        }
        Relationships: []
      }
      messages: {
        Row: {
          contenu: string
          conversation_id: string
          created_at: string
          id: string
          sender_id: string
        }
        Insert: {
          contenu: string
          conversation_id: string
          created_at?: string
          id?: string
          sender_id: string
        }
        Update: {
          contenu?: string
          conversation_id?: string
          created_at?: string
          id?: string
          sender_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "messages_conversation_id_fkey"
            columns: ["conversation_id"]
            isOneToOne: false
            referencedRelation: "conversations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "messages_sender_id_fkey"
            columns: ["sender_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      notifications: {
        Row: {
          contenu: string | null
          created_at: string
          id: string
          lu: boolean
          profile_id: string
          titre: string
        }
        Insert: {
          contenu?: string | null
          created_at?: string
          id?: string
          lu?: boolean
          profile_id: string
          titre: string
        }
        Update: {
          contenu?: string | null
          created_at?: string
          id?: string
          lu?: boolean
          profile_id?: string
          titre?: string
        }
        Relationships: [
          {
            foreignKeyName: "notifications_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      olympiads: {
        Row: {
          created_at: string
          description: string
          edition: string
          ends_on: string | null
          id: string
          is_featured: boolean
          location: string | null
          slug: string
          sort_order: number
          starts_on: string | null
          title: string
          updated_at: string
          year: number
        }
        Insert: {
          created_at?: string
          description: string
          edition: string
          ends_on?: string | null
          id?: string
          is_featured?: boolean
          location?: string | null
          slug: string
          sort_order?: number
          starts_on?: string | null
          title: string
          updated_at?: string
          year: number
        }
        Update: {
          created_at?: string
          description?: string
          edition?: string
          ends_on?: string | null
          id?: string
          is_featured?: boolean
          location?: string | null
          slug?: string
          sort_order?: number
          starts_on?: string | null
          title?: string
          updated_at?: string
          year?: number
        }
        Relationships: []
      }
      orientation_messages: {
        Row: {
          contenu: string
          created_at: string
          eleve_id: string
          id: string
          role: string
        }
        Insert: {
          contenu: string
          created_at?: string
          eleve_id: string
          id?: string
          role: string
        }
        Update: {
          contenu?: string
          created_at?: string
          eleve_id?: string
          id?: string
          role?: string
        }
        Relationships: [
          {
            foreignKeyName: "orientation_messages_eleve_id_fkey"
            columns: ["eleve_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      orientation_profils: {
        Row: {
          created_at: string
          eleve_id: string
          filiere_cible: string | null
          id: string
          niveau_scolaire: string
          systeme_educatif: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          eleve_id: string
          filiere_cible?: string | null
          id?: string
          niveau_scolaire: string
          systeme_educatif?: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          eleve_id?: string
          filiere_cible?: string | null
          id?: string
          niveau_scolaire?: string
          systeme_educatif?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "orientation_profils_eleve_id_fkey"
            columns: ["eleve_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      pillars: {
        Row: {
          created_at: string
          description: string
          id: string
          number: string
          slug: string
          sort_order: number
          title: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          description: string
          id?: string
          number: string
          slug: string
          sort_order?: number
          title: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          description?: string
          id?: string
          number?: string
          slug?: string
          sort_order?: number
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      predictions: {
        Row: {
          calcule_le: string
          eleve_id: string
          id: string
          matiere_id: string | null
          probabilite_reussite: number
          score_confiance: number
          tendance: string | null
        }
        Insert: {
          calcule_le?: string
          eleve_id: string
          id?: string
          matiere_id?: string | null
          probabilite_reussite?: number
          score_confiance?: number
          tendance?: string | null
        }
        Update: {
          calcule_le?: string
          eleve_id?: string
          id?: string
          matiere_id?: string | null
          probabilite_reussite?: number
          score_confiance?: number
          tendance?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "predictions_eleve_id_fkey"
            columns: ["eleve_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "predictions_matiere_id_fkey"
            columns: ["matiere_id"]
            isOneToOne: false
            referencedRelation: "matieres"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          avatar_url: string | null
          created_at: string
          etablissement_id: string | null
          full_name: string | null
          id: string
          niveau: string
          nom: string | null
          prenom: string | null
          role: Database["public"]["Enums"]["app_role"]
          statut_validation: Database["public"]["Enums"]["validation_statut"]
          updated_at: string
          xp_total: number
        }
        Insert: {
          avatar_url?: string | null
          created_at?: string
          etablissement_id?: string | null
          full_name?: string | null
          id: string
          niveau?: string
          nom?: string | null
          prenom?: string | null
          role?: Database["public"]["Enums"]["app_role"]
          statut_validation?: Database["public"]["Enums"]["validation_statut"]
          updated_at?: string
          xp_total?: number
        }
        Update: {
          avatar_url?: string | null
          created_at?: string
          etablissement_id?: string | null
          full_name?: string | null
          id?: string
          niveau?: string
          nom?: string | null
          prenom?: string | null
          role?: Database["public"]["Enums"]["app_role"]
          statut_validation?: Database["public"]["Enums"]["validation_statut"]
          updated_at?: string
          xp_total?: number
        }
        Relationships: [
          {
            foreignKeyName: "profiles_etablissement_id_fkey"
            columns: ["etablissement_id"]
            isOneToOne: false
            referencedRelation: "etablissements"
            referencedColumns: ["id"]
          },
        ]
      }
      programmes: {
        Row: {
          classe_id: string | null
          created_at: string
          description: string | null
          etablissement_id: string | null
          id: string
          matiere_id: string | null
          titre: string
          updated_at: string
        }
        Insert: {
          classe_id?: string | null
          created_at?: string
          description?: string | null
          etablissement_id?: string | null
          id?: string
          matiere_id?: string | null
          titre: string
          updated_at?: string
        }
        Update: {
          classe_id?: string | null
          created_at?: string
          description?: string | null
          etablissement_id?: string | null
          id?: string
          matiere_id?: string | null
          titre?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "programmes_classe_id_fkey"
            columns: ["classe_id"]
            isOneToOne: false
            referencedRelation: "classes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "programmes_etablissement_id_fkey"
            columns: ["etablissement_id"]
            isOneToOne: false
            referencedRelation: "etablissements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "programmes_matiere_id_fkey"
            columns: ["matiere_id"]
            isOneToOne: false
            referencedRelation: "matieres"
            referencedColumns: ["id"]
          },
        ]
      }
      progression_concepts: {
        Row: {
          concept_id: string
          created_at: string
          eleve_id: string
          id: string
          termine: boolean
          updated_at: string
        }
        Insert: {
          concept_id: string
          created_at?: string
          eleve_id: string
          id?: string
          termine?: boolean
          updated_at?: string
        }
        Update: {
          concept_id?: string
          created_at?: string
          eleve_id?: string
          id?: string
          termine?: boolean
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "progression_concepts_concept_id_fkey"
            columns: ["concept_id"]
            isOneToOne: false
            referencedRelation: "concepts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "progression_concepts_eleve_id_fkey"
            columns: ["eleve_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      questions: {
        Row: {
          concept_id: string | null
          created_at: string
          enonce: string
          examen_id: string
          id: string
          options: Json
          ordre: number
          points: number
          reponse_correcte: string | null
          type: string
        }
        Insert: {
          concept_id?: string | null
          created_at?: string
          enonce: string
          examen_id: string
          id?: string
          options?: Json
          ordre?: number
          points?: number
          reponse_correcte?: string | null
          type?: string
        }
        Update: {
          concept_id?: string | null
          created_at?: string
          enonce?: string
          examen_id?: string
          id?: string
          options?: Json
          ordre?: number
          points?: number
          reponse_correcte?: string | null
          type?: string
        }
        Relationships: [
          {
            foreignKeyName: "questions_concept_id_fkey"
            columns: ["concept_id"]
            isOneToOne: false
            referencedRelation: "concepts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "questions_examen_id_fkey"
            columns: ["examen_id"]
            isOneToOne: false
            referencedRelation: "examens"
            referencedColumns: ["id"]
          },
        ]
      }
      ressources_mediatheque: {
        Row: {
          created_at: string
          description: string | null
          etablissement_id: string | null
          id: string
          matiere_id: string | null
          statut_validation: Database["public"]["Enums"]["validation_statut"]
          titre: string
          type: Database["public"]["Enums"]["ressource_type"]
          updated_at: string
          uploaded_by: string | null
          url_storage: string
          xp_valeur: number
        }
        Insert: {
          created_at?: string
          description?: string | null
          etablissement_id?: string | null
          id?: string
          matiere_id?: string | null
          statut_validation?: Database["public"]["Enums"]["validation_statut"]
          titre: string
          type: Database["public"]["Enums"]["ressource_type"]
          updated_at?: string
          uploaded_by?: string | null
          url_storage: string
          xp_valeur?: number
        }
        Update: {
          created_at?: string
          description?: string | null
          etablissement_id?: string | null
          id?: string
          matiere_id?: string | null
          statut_validation?: Database["public"]["Enums"]["validation_statut"]
          titre?: string
          type?: Database["public"]["Enums"]["ressource_type"]
          updated_at?: string
          uploaded_by?: string | null
          url_storage?: string
          xp_valeur?: number
        }
        Relationships: [
          {
            foreignKeyName: "ressources_mediatheque_etablissement_id_fkey"
            columns: ["etablissement_id"]
            isOneToOne: false
            referencedRelation: "etablissements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ressources_mediatheque_matiere_id_fkey"
            columns: ["matiere_id"]
            isOneToOne: false
            referencedRelation: "matieres"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ressources_mediatheque_uploaded_by_fkey"
            columns: ["uploaded_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      resultats_examens: {
        Row: {
          date_passage: string
          eleve_id: string
          examen_id: string
          id: string
          reponses: Json
          score: number
        }
        Insert: {
          date_passage?: string
          eleve_id: string
          examen_id: string
          id?: string
          reponses?: Json
          score?: number
        }
        Update: {
          date_passage?: string
          eleve_id?: string
          examen_id?: string
          id?: string
          reponses?: Json
          score?: number
        }
        Relationships: [
          {
            foreignKeyName: "resultats_examens_eleve_id_fkey"
            columns: ["eleve_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "resultats_examens_examen_id_fkey"
            columns: ["examen_id"]
            isOneToOne: false
            referencedRelation: "examens"
            referencedColumns: ["id"]
          },
        ]
      }
      student_applications: {
        Row: {
          city: string | null
          country: string
          created_at: string
          email: string
          full_name: string
          id: string
          motivation: string
          phone: string | null
          pillar_interest: Database["public"]["Enums"]["pillar"] | null
          school: string | null
          school_level: string
          status: Database["public"]["Enums"]["application_status"]
          updated_at: string
        }
        Insert: {
          city?: string | null
          country: string
          created_at?: string
          email: string
          full_name: string
          id?: string
          motivation: string
          phone?: string | null
          pillar_interest?: Database["public"]["Enums"]["pillar"] | null
          school?: string | null
          school_level: string
          status?: Database["public"]["Enums"]["application_status"]
          updated_at?: string
        }
        Update: {
          city?: string | null
          country?: string
          created_at?: string
          email?: string
          full_name?: string
          id?: string
          motivation?: string
          phone?: string | null
          pillar_interest?: Database["public"]["Enums"]["pillar"] | null
          school?: string | null
          school_level?: string
          status?: Database["public"]["Enums"]["application_status"]
          updated_at?: string
        }
        Relationships: []
      }
      validations_enseignants: {
        Row: {
          created_at: string
          date_validation: string | null
          enseignant_id: string
          etablissement_id: string
          id: string
          statut: Database["public"]["Enums"]["validation_statut"]
          valide_par: string | null
        }
        Insert: {
          created_at?: string
          date_validation?: string | null
          enseignant_id: string
          etablissement_id: string
          id?: string
          statut?: Database["public"]["Enums"]["validation_statut"]
          valide_par?: string | null
        }
        Update: {
          created_at?: string
          date_validation?: string | null
          enseignant_id?: string
          etablissement_id?: string
          id?: string
          statut?: Database["public"]["Enums"]["validation_statut"]
          valide_par?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "validations_enseignants_enseignant_id_fkey"
            columns: ["enseignant_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "validations_enseignants_etablissement_id_fkey"
            columns: ["etablissement_id"]
            isOneToOne: false
            referencedRelation: "etablissements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "validations_enseignants_valide_par_fkey"
            columns: ["valide_par"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      xp_transactions: {
        Row: {
          created_at: string
          description: string | null
          id: string
          montant: number
          profile_id: string
          source: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          id?: string
          montant: number
          profile_id: string
          source: string
        }
        Update: {
          created_at?: string
          description?: string | null
          id?: string
          montant?: number
          profile_id?: string
          source?: string
        }
        Relationships: [
          {
            foreignKeyName: "xp_transactions_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      app_role:
        | "student"
        | "teacher"
        | "admin"
        | "chef_etablissement"
        | "super_admin"
      application_status: "pending" | "reviewing" | "accepted" | "rejected"
      course_level: "debutant" | "intermediaire" | "avance"
      pillar:
        | "education"
        | "citoyennete"
        | "identite_culture"
        | "orientation"
        | "developpement"
        | "entrepreneuriat"
        | "sante_bien_etre"
        | "culture_generale"
      ressource_type: "video" | "audio" | "document"
      validation_statut: "en_attente" | "approuve" | "rejete"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      app_role: [
        "student",
        "teacher",
        "admin",
        "chef_etablissement",
        "super_admin",
      ],
      application_status: ["pending", "reviewing", "accepted", "rejected"],
      course_level: ["debutant", "intermediaire", "avance"],
      pillar: [
        "education",
        "citoyennete",
        "identite_culture",
        "orientation",
        "developpement",
        "entrepreneuriat",
        "sante_bien_etre",
        "culture_generale",
      ],
      ressource_type: ["video", "audio", "document"],
      validation_statut: ["en_attente", "approuve", "rejete"],
    },
  },
} as const
