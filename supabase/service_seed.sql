-- Seed categories, services, and service attributes from the Enso category CSV.

insert into public.category (name)
select seed.category_name from (values
  ('Signature Wellness Collection'),
  ('Premium Therapy Collection'),
  ('Membership'),
  ('Package')
) as seed(category_name)
where not exists (select 1 from public.category existing where existing.name = seed.category_name);

insert into public.service (name, category_id)
select seed.service_name, category.id from (values
  ('Signature Wellness Collection', 'Relaxation Massage'),
  ('Signature Wellness Collection', 'Chinese Acupressure'),
  ('Signature Wellness Collection', 'Deep Tissue Massage'),
  ('Signature Wellness Collection', 'Foot Reflexology'),


  ('Signature Wellness Collection', 'Extra time'),
  ('Premium Therapy Collection', 'Lymphatic Drainage Massage'),
  ('Premium Therapy Collection', 'Hot Stone Massage'),
  ('Premium Therapy Collection', 'extra time'),
  ('Membership', 'Annual Membership'),
  ('Package', '60-mins value pack'),
  ('Package', '30-mins value pack')
) as seed(category_name, service_name)
join public.category category on category.name = seed.category_name
where not exists (select 1 from public.service existing where existing.category_id = category.id and existing.name = seed.service_name);

-- Package tiers use sessions; timed services use duration. Membership has neither.
insert into public.service_attribute (service_id, duration, sessions, price)
select service.id, seed.duration, seed.sessions, seed.price from (values
  ('Signature Wellness Collection', 'Relaxation Massage', 30, null, 68),
  ('Signature Wellness Collection', 'Relaxation Massage', 60, null, 118),
  ('Signature Wellness Collection', 'Relaxation Massage', 90, null, 168),
  ('Signature Wellness Collection', 'Relaxation Massage', 120, null, 218),
  ('Signature Wellness Collection', 'Chinese Acupressure', 30, null, 68),
  ('Signature Wellness Collection', 'Chinese Acupressure', 60, null, 118),
  ('Signature Wellness Collection', 'Chinese Acupressure', 90, null, 168),
  ('Signature Wellness Collection', 'Chinese Acupressure', 120, null, 218),
  ('Signature Wellness Collection', 'Deep Tissue Massage', 30, null, 68),
  ('Signature Wellness Collection', 'Deep Tissue Massage', 60, null, 118),
  ('Signature Wellness Collection', 'Deep Tissue Massage', 90, null, 168),
  ('Signature Wellness Collection', 'Deep Tissue Massage', 120, null, 218),
  ('Signature Wellness Collection', 'Foot Reflexology', 30, null, 68),
  ('Signature Wellness Collection', 'Foot Reflexology', 60, null, 118),
  ('Signature Wellness Collection', 'Foot Reflexology', 90, null, 168),
  ('Signature Wellness Collection', 'Foot Reflexology', 120, null, 218),


  ('Signature Wellness Collection', 'Extra time', 10, null, 20),
  ('Signature Wellness Collection', 'Extra time', 15, null, 30),
  ('Signature Wellness Collection', 'Extra time', 20, null, 40),
  ('Signature Wellness Collection', 'Extra time', 30, null, 60),
  ('Premium Therapy Collection', 'Lymphatic Drainage Massage', 30, null, 88),
  ('Premium Therapy Collection', 'Lymphatic Drainage Massage', 60, null, 138),
  ('Premium Therapy Collection', 'Lymphatic Drainage Massage', 90, null, 188),
  ('Premium Therapy Collection', 'Lymphatic Drainage Massage', 120, null, 238),
  ('Premium Therapy Collection', 'Hot Stone Massage', 30, null, 88),
  ('Premium Therapy Collection', 'Hot Stone Massage', 60, null, 138),
  ('Premium Therapy Collection', 'Hot Stone Massage', 90, null, 188),
  ('Premium Therapy Collection', 'Hot Stone Massage', 120, null, 238),
  ('Premium Therapy Collection', 'extra time', 10, null, 25),
  ('Premium Therapy Collection', 'extra time', 15, null, 35),
  ('Premium Therapy Collection', 'extra time', 20, null, 45),
  ('Premium Therapy Collection', 'extra time', 30, null, 65),
  ('Membership', 'Annual Membership', null, null, 200),
  ('Package', '60-mins value pack', null, 3, 354),
  ('Package', '60-mins value pack', null, 5, 590),
  ('Package', '60-mins value pack', null, 10, 1180),
  ('Package', '30-mins value pack', null, 3, 204),
  ('Package', '30-mins value pack', null, 5, 340),
  ('Package', '30-mins value pack', null, 10, 680)
) as seed(category_name, service_name, duration, sessions, price)
join public.category category on category.name = seed.category_name
join public.service service on service.category_id = category.id and service.name = seed.service_name
where not exists (
  select 1 from public.service_attribute existing
  where existing.service_id = service.id
    and existing.duration is not distinct from seed.duration
    and existing.sessions is not distinct from seed.sessions
);

-- Keep regular package prices separate from member prices, and refresh these
-- values on reruns when the attribute rows already exist.
update public.service_attribute as sa
set price = case
      when category.name = 'Package'
        and service.name = '60-mins value pack'
        and sa.sessions = 3 then 354
      when category.name = 'Package'
        and service.name = '60-mins value pack'
        and sa.sessions = 5 then 590
      when category.name = 'Package'
        and service.name = '60-mins value pack'
        and sa.sessions = 10 then 1180
      when category.name = 'Package'
        and service.name = '30-mins value pack'
        and sa.sessions = 3 then 204
      when category.name = 'Package'
        and service.name = '30-mins value pack'
        and sa.sessions = 5 then 340
      when category.name = 'Package'
        and service.name = '30-mins value pack'
        and sa.sessions = 10 then 680
      else sa.price
    end,
    membership_price = case
      when category.name = 'Package'
        and service.name = '60-mins value pack'
        and sa.sessions = 3 then 299
      when category.name = 'Package'
        and service.name = '60-mins value pack'
        and sa.sessions = 5 then 480
      when category.name = 'Package'
        and service.name = '60-mins value pack'
        and sa.sessions = 10 then 880
      when category.name = 'Package'
        and service.name = '30-mins value pack'
        and sa.sessions = 3 then 180
      when category.name = 'Package'
        and service.name = '30-mins value pack'
        and sa.sessions = 5 then 280
      when category.name = 'Package'
        and service.name = '30-mins value pack'
        and sa.sessions = 10 then 500
      when category.name in (
        'Signature Wellness Collection', 'Premium Therapy Collection'
      ) and lower(service.name) <> 'extra time'
        and sa.duration = 30 then sa.price - 20
      when category.name in (
        'Signature Wellness Collection', 'Premium Therapy Collection'
      ) and lower(service.name) <> 'extra time'
        and sa.duration in (60, 90, 120) then sa.price - 30
      else sa.membership_price
    end
from public.service as service
join public.category as category on category.id = service.category_id
where sa.service_id = service.id
  and (
    category.name in (
      'Signature Wellness Collection', 'Premium Therapy Collection'
    )
    or (category.name = 'Package' and service.name in (
      '60-mins value pack', '30-mins value pack'
    ))
  );

-- Make every therapist available for every service in the seeded catalog.
insert into public.service_therapist (therapist_id, service_id)
select therapist.id, service.id
from public."user" as therapist
cross join public.service as service
where therapist.role = 'therapist'
  and not exists (
    select 1
    from public.service_therapist as existing
    where existing.therapist_id = therapist.id
      and existing.service_id = service.id
  );
