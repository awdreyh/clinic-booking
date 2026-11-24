-- Optional member price for each service duration/session tier.
alter table public.service_attribute
  add column membership_price numeric(10,2);
