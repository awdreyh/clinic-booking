-- Seed categories, services, and service attributes from the Enso category CSV.

insert into public.category (name)
select jsonb_build_object('en', seed.category_name, 'zh', seed.category_name_zh) from (values
  ('Signature Wellness Collection', '臻选养生系列'),
  ('Premium Therapy Collection', '尊享理疗系列'),
  ('Membership', '会员计划'),
  ('Package', '疗程套餐')
) as seed(category_name, category_name_zh)
where not exists (select 1 from public.category existing where existing.name->>'en' = seed.category_name);

insert into public.service (name, category_id)
select jsonb_build_object('en', seed.service_name, 'zh', seed.service_name_zh), category.id from (values
  ('Signature Wellness Collection', 'Relaxation Massage', '舒缓按摩'),
  ('Signature Wellness Collection', 'Chinese Acupressure', '中式指压'),
  ('Signature Wellness Collection', 'Deep Tissue Massage', '深层组织按摩'),
  ('Signature Wellness Collection', 'Foot Reflexology', '足底反射疗法'),


  ('Signature Wellness Collection', 'Extra time', '加时'),
  ('Premium Therapy Collection', 'Lymphatic Drainage Massage', '淋巴引流按摩'),
  ('Premium Therapy Collection', 'Hot Stone Massage', '热石按摩'),
  ('Premium Therapy Collection', 'extra time', '加时'),
  ('Membership', 'Annual Membership', '年度会员'),
  ('Package', '60-mins value pack', '60分钟疗程套餐'),
  ('Package', '30-mins value pack', '30分钟疗程套餐')
) as seed(category_name, service_name, service_name_zh)
join public.category category on category.name->>'en' = seed.category_name
where not exists (select 1 from public.service existing where existing.category_id = category.id and existing.name->>'en' = seed.service_name);

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
join public.category category on category.name->>'en' = seed.category_name
join public.service service on service.category_id = category.id and service.name->>'en' = seed.service_name
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
      when category.name->>'en' = 'Package'
        and service.name->>'en' = '60-mins value pack'
        and sa.sessions = 3 then 354
      when category.name->>'en' = 'Package'
        and service.name->>'en' = '60-mins value pack'
        and sa.sessions = 5 then 590
      when category.name->>'en' = 'Package'
        and service.name->>'en' = '60-mins value pack'
        and sa.sessions = 10 then 1180
      when category.name->>'en' = 'Package'
        and service.name->>'en' = '30-mins value pack'
        and sa.sessions = 3 then 204
      when category.name->>'en' = 'Package'
        and service.name->>'en' = '30-mins value pack'
        and sa.sessions = 5 then 340
      when category.name->>'en' = 'Package'
        and service.name->>'en' = '30-mins value pack'
        and sa.sessions = 10 then 680
      else sa.price
    end,
    membership_price = case
      when category.name->>'en' = 'Package'
        and service.name->>'en' = '60-mins value pack'
        and sa.sessions = 3 then 299
      when category.name->>'en' = 'Package'
        and service.name->>'en' = '60-mins value pack'
        and sa.sessions = 5 then 480
      when category.name->>'en' = 'Package'
        and service.name->>'en' = '60-mins value pack'
        and sa.sessions = 10 then 880
      when category.name->>'en' = 'Package'
        and service.name->>'en' = '30-mins value pack'
        and sa.sessions = 3 then 180
      when category.name->>'en' = 'Package'
        and service.name->>'en' = '30-mins value pack'
        and sa.sessions = 5 then 280
      when category.name->>'en' = 'Package'
        and service.name->>'en' = '30-mins value pack'
        and sa.sessions = 10 then 500
      when category.name->>'en' in (
        'Signature Wellness Collection', 'Premium Therapy Collection'
      ) and lower(service.name->>'en') <> 'extra time'
        and sa.duration = 30 then sa.price - 20
      when category.name->>'en' in (
        'Signature Wellness Collection', 'Premium Therapy Collection'
      ) and lower(service.name->>'en') <> 'extra time'
        and sa.duration in (60, 90, 120) then sa.price - 30
      else sa.membership_price
    end
from public.service as service
join public.category as category on category.id = service.category_id
where sa.service_id = service.id
  and (
    category.name->>'en' in (
      'Signature Wellness Collection', 'Premium Therapy Collection'
    )
    or (category.name->>'en' = 'Package' and service.name->>'en' in (
      '60-mins value pack', '30-mins value pack'
    ))
  );


