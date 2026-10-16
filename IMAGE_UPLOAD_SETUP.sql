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

-- 4. image overrides: kisi bhi prompt (built-in ya community) par manual image
create table if not exists image_overrides (
  prompt_key text primary key,
  image_url text not null,
  created_at timestamptz default now()
);
alter table image_overrides enable row level security;

drop policy if exists "Public read image overrides" on image_overrides;
create policy "Public read image overrides"
  on image_overrides for select
  using (true);

drop policy if exists "Admin manage image overrides" on image_overrides;
create policy "Admin manage image overrides"
  on image_overrides for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');
