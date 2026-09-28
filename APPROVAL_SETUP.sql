-- Mr Shah Prompts: approval workflow
-- Run this once in Supabase SQL Editor after deploying the new ZIP.
-- Existing prompts are marked approved so nothing disappears.

alter table public.prompts
  add column if not exists status text not null default 'pending';

update public.prompts
set status = 'approved'
where status is null or status = 'pending';

alter table public.prompts
  drop constraint if exists prompts_status_check;

alter table public.prompts
  add constraint prompts_status_check
  check (status in ('pending','approved','rejected'));

create index if not exists prompts_status_created_at_idx
  on public.prompts(status, created_at desc);
