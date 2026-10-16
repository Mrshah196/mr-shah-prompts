-- ============================================================
-- Mr Shah Prompts — IMAGE UPLOAD SETUP (sirf ek dafa run karein)
-- Supabase Dashboard → apna project → SQL Editor → New query
-- Neeche ka poora code paste kar ke "Run" dabayein.
-- ============================================================

-- 1. prompts table mein image_url column
alter table prompts
  add column if not exists image_url text;

-- 2. public storage bucket (prompt preview images ke liye)
insert into storage.buckets (id, name, public)
values ('prompt-images', 'prompt-images', true)
on conflict (id) do update set public = true;

-- 3. storage policies: sab dekh sakte hain, sirf login admin upload/delete kar sakta hai
drop policy if exists "Public read prompt images" on storage.objects;
create policy "Public read prompt images"
  on storage.objects for select
  using (bucket_id = 'prompt-images');

drop policy if exists "Admin upload prompt images" on storage.objects;
create policy "Admin upload prompt images"
  on storage.objects for insert
  with check (bucket_id = 'prompt-images' and auth.role() = 'authenticated');

drop policy if exists "Admin update prompt images" on storage.objects;
create policy "Admin update prompt images"
  on storage.objects for update
  using (bucket_id = 'prompt-images' and auth.role() = 'authenticated');

drop policy if exists "Admin delete prompt images" on storage.objects;
create policy "Admin delete prompt images"
  on storage.objects for delete
  using (bucket_id = 'prompt-images' and auth.role() = 'authenticated');
