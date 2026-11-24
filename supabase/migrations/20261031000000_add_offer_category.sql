-- Group value packages and memberships under a parent "Offer" category.
insert into public.category (name, description)
select 'Offer', 'Value packages and memberships for regular visits.'
where not exists (
  select 1 from public.category existing where existing.name = 'Offer'
);

update public.category child
set parent_id = offer.id
from public.category offer
where offer.name = 'Offer'
  and child.name in ('Package', 'Membership')
  and child.id <> offer.id
  and child.parent_id is null;
