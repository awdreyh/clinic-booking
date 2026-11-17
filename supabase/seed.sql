insert into public.category (name, description)
select seed.name, seed.description
from (
  values
    (
      'Signature Wellness Collection',
      'Our Signature Wellness Collection features Enso''s core therapeutic massage treatments, designed to relieve tension, restore balance, and support your overall wellbeing. Whether you seek deep muscle relief, gentle relaxation, traditional Chinese acupressure, or revitalising foot reflexology, each treatment is tailored to your individual needs for a personalised wellness experience.'
    ),
    (
      'Premium Therapy Collection',
      'Our Premium Therapy Collection offers specialised treatments that enhance the benefits of traditional massage through advanced therapeutic techniques. Featuring Hot Stone Therapy and Lymphatic Drainage Therapy, these treatments help improve circulation, encourage detoxification, ease muscular tension, and promote deep relaxation and recovery.'
    ),
    (
      'Offer',
      'Value packages and memberships for regular visits.'
    )
) as seed(name, description)
where not exists (
  select 1
  from public.category existing
  where existing.name = seed.name
);

-- Package and Membership are child categories of Offer.
insert into public.category (name, parent_id)
select seed.name, offer.id
from (values ('Package'), ('Membership')) as seed(name)
join public.category offer on offer.name = 'Offer'
where not exists (
  select 1
  from public.category existing
  where existing.name = seed.name
);

insert into public.service (name, image, category_id)
select seed.service_name, seed.image, category.id from (values
  ('Signature Wellness Collection', 'Relaxation Massage', 'assets/services/default.jpg'),
  ('Signature Wellness Collection', 'Chinese Acupressure', 'assets/services/chinese-acupressure.jpg'),
  ('Signature Wellness Collection', 'Deep Tissue Massage', 'assets/services/default.jpg'),
  ('Signature Wellness Collection', 'Foot Reflexology', 'assets/services/reflexology.jpg'),
  ('Signature Wellness Collection', 'Extra time', 'assets/services/default.jpg'),
  ('Premium Therapy Collection', 'Lymphatic Drainage Massage', 'assets/services/lymphatic-drainage-massage.jpg'),
  ('Premium Therapy Collection', 'Hot Stone Massage', 'assets/services/hotstone.jpg'),
  ('Premium Therapy Collection', 'extra time', 'assets/services/default.jpg'),
  ('Membership', 'Annual Membership', 'assets/services/default.jpg'),
  ('Package', '60-mins value pack', 'assets/services/default.jpg'),
  ('Package', '30-mins value pack', 'assets/services/default.jpg')
) as seed(category_name, service_name, image)
join public.category category on category.name = seed.category_name
where not exists (
  select 1
  from public.service existing
  where existing.name = seed.service_name
    and existing.category_id = category.id
);

update public.service set image = case
  when lower(name) like '%reflexology%' then 'assets/services/reflexology.jpg'
  when lower(name) like '%lymphatic%' then 'assets/services/lymphatic-drainage-massage.jpg'
  when lower(name) like '%aromatherapy%' or lower(name) like '%meridian%' then 'assets/services/aromatherapy-meridian-massage.jpg'
  when lower(name) like '%acupressure%' then 'assets/services/chinese-acupressure.jpg'
  when lower(name) like '%hot stone%' or lower(name) like '%hotstone%' then 'assets/services/hotstone.jpg'
  else 'assets/services/default.jpg'
end;

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
