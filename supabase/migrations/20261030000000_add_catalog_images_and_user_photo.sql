alter table public.category
  add column if not exists image text;

alter table public.service
  add column if not exists image text;

alter table public."user"
  add column if not exists photo text;
