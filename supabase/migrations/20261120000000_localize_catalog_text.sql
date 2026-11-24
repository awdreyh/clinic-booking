-- Store catalog labels and descriptions by language. Existing text is retained as English.
alter table public.category
  alter column name type jsonb using jsonb_build_object('en', name),
  alter column description type jsonb using case
    when description is null then null
    else jsonb_build_object('en', description)
  end;

alter table public.service
  alter column name type jsonb using jsonb_build_object('en', name),
  alter column description type jsonb using case
    when description is null then null
    else jsonb_build_object('en', description)
  end;
