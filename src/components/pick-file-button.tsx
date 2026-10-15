import { useRef, type ReactNode } from "react";
import { Button } from "@/components/ui/button";

/** Bouton qui ouvre le sélecteur de fichiers (ou l'appareil photo avec `capture`). */
export function PickFileButton({
  icon,
  label,
  accept,
  multiple,
  capture,
  onFiles,
  disabled,
}: {
  icon: ReactNode;
  label: string;
  accept: string;
  multiple?: boolean | undefined;
  capture?: boolean | undefined;
  onFiles: (files: FileList | null) => void;
  disabled?: boolean | undefined;
}) {
  const ref = useRef<HTMLInputElement>(null);
  return (
    <>
      <Button
        type="button"
        variant="outline"
        size="sm"
        className="rounded-xl"
        disabled={disabled}
        onClick={() => ref.current?.click()}
      >
        {icon} {label}
      </Button>
      <input
        ref={ref}
        type="file"
        hidden
        accept={accept}
        multiple={multiple}
        {...(capture ? { capture: "environment" as const } : {})}
        onChange={(e) => {
          onFiles(e.target.files);
          e.target.value = "";
        }}
      />
    </>
  );
}
