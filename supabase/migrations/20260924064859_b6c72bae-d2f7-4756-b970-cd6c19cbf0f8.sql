CREATE POLICY "Enseignant cree ses classes"
ON public.classes
FOR INSERT
TO authenticated
WITH CHECK (
  private.is_teacher(auth.uid())
  AND enseignant_id = auth.uid()
  AND etablissement_id = private.etab(auth.uid())
);

CREATE POLICY "Enseignant supprime sa classe"
ON public.classes
FOR DELETE
TO authenticated
USING (enseignant_id = auth.uid());