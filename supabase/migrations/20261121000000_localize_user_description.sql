-- Store user descriptions by language, matching service descriptions.
alter table public."user"
  alter column description type jsonb using case
    when description is null then null
    else jsonb_build_object('en', description)
  end;
