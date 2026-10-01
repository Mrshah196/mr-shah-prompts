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


-- Duplicate prompt protection
-- Prevents the same prompt text (ignoring case and repeated whitespace)
-- from being inserted or updated more than once. Existing rows are preserved.
create or replace function public.prevent_duplicate_prompt()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if exists (
    select 1 from public.prompts p
    where p.id <> coalesce(new.id, -1)
      and lower(regexp_replace(trim(coalesce(p.prompt, '')), '\s+', ' ', 'g'))
          = lower(regexp_replace(trim(coalesce(new.prompt, '')), '\s+', ' ', 'g'))
  ) then
    raise exception 'prompt_no_duplicates: This prompt already exists.';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_prevent_duplicate_prompt on public.prompts;
create trigger trg_prevent_duplicate_prompt
before insert or update of prompt on public.prompts
for each row execute function public.prevent_duplicate_prompt();
