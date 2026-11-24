insert into public.category (name, description)
select seed.name, seed.description
from (
  values
    (
      '{"en":"Signature Wellness Collection","zh":"臻选养生系列"}'::jsonb,
      '{"en":"Our Signature Wellness Collection features Enso''s core therapeutic massage treatments, designed to relieve tension, restore balance, and support your overall wellbeing. Whether you seek deep muscle relief, gentle relaxation, traditional Chinese acupressure, or revitalising foot reflexology, each treatment is tailored to your individual needs for a personalised wellness experience.","zh":"è‡»é€‰å…»ç”Ÿç³»åˆ—æ±‡é›† Enso æ ¸å¿ƒæŒ‰æ‘©æŠ¤ç†ï¼Œæ—¨åœ¨ç¼“è§£ç´§å¼ ã€æ¢å¤å¹³è¡¡å¹¶æå‡æ•´ä½“å¥åº·ã€‚æ— è®ºæ‚¨éœ€è¦æ·±å±‚è‚Œè‚‰æ”¾æ¾ã€èˆ’ç¼“æŒ‰æ‘©ã€ä¼ ç»Ÿä¸­å¼æŒ‡åŽ‹æˆ–ç„•æ´»è¶³åº•åå°„ç–—æ³•ï¼Œæ¯é¡¹æŠ¤ç†éƒ½ä¼šæ ¹æ®æ‚¨çš„éœ€æ±‚é‡èº«å®šåˆ¶ã€‚"}'::jsonb
    ),
    (
      '{"en":"Premium Therapy Collection","zh":"尊享理疗系列"}'::jsonb,
      '{"en":"Our Premium Therapy Collection offers specialised treatments that enhance the benefits of traditional massage through advanced therapeutic techniques. Featuring Hot Stone Therapy and Lymphatic Drainage Therapy, these treatments help improve circulation, encourage detoxification, ease muscular tension, and promote deep relaxation and recovery.","zh":"å°Šäº«ç†ç–—ç³»åˆ—é‡‡ç”¨ä¸“ä¸šç–—æ³•æå‡ä¼ ç»ŸæŒ‰æ‘©çš„æ•ˆæžœï¼ŒåŒ…å«çƒ­çŸ³ç–—æ³•å’Œæ·‹å·´å¼•æµæŒ‰æ‘©ï¼Œå¸®åŠ©ä¿ƒè¿›å¾ªçŽ¯ã€èˆ’ç¼“è‚Œè‚‰ç´§å¼ ï¼Œå¹¶å¸¦æ¥æ·±åº¦æ”¾æ¾ä¸Žæ¢å¤ã€‚"}'::jsonb
    ),
    (
      '{"en":"Offer","zh":"优惠项目"}'::jsonb,
      '{"en":"Value packages and memberships for regular visits.","zh":"é€‚åˆå®šæœŸåˆ°è®¿çš„å¥—é¤ä¸Žä¼šå‘˜è®¡åˆ’ã€‚"}'::jsonb
    )
) as seed(name, description)
where not exists (
  select 1
  from public.category existing
  where existing.name->>'en' = seed.name->>'en'
);

-- Refresh localized labels/descriptions for categories created by earlier seed runs.
update public.category as existing
set name = seed.name,
    description = seed.description
from (values
  ('Signature Wellness Collection', '{"en":"Signature Wellness Collection","zh":"臻选养生系列"}'::jsonb,
   '{"en":"Our Signature Wellness Collection features Enso''s core therapeutic massage treatments, designed to relieve tension, restore balance, and support your overall wellbeing. Whether you seek deep muscle relief, gentle relaxation, traditional Chinese acupressure, or revitalising foot reflexology, each treatment is tailored to your individual needs for a personalised wellness experience.","zh":"臻选养生系列汇集 Enso 核心按摩护理，旨在缓解紧张、恢复平衡并提升整体健康。无论您需要深层肌肉放松、舒缓按摩、传统中式指压或足底反射疗法，每项护理都会根据您的需求量身定制。"}'::jsonb),
  ('Premium Therapy Collection', '{"en":"Premium Therapy Collection","zh":"尊享理疗系列"}'::jsonb,
   '{"en":"Our Premium Therapy Collection offers specialised treatments that enhance the benefits of traditional massage through advanced therapeutic techniques. Featuring Hot Stone Therapy and Lymphatic Drainage Therapy, these treatments help improve circulation, encourage detoxification, ease muscular tension, and promote deep relaxation and recovery.","zh":"尊享理疗系列采用专业疗法提升传统按摩的效果，包含热石疗法和淋巴引流按摩，帮助促进循环、舒缓肌肉紧张，并带来深度放松与恢复。"}'::jsonb),
  ('Offer', '{"en":"Offer","zh":"优惠项目"}'::jsonb,
   '{"en":"Value packages and memberships for regular visits.","zh":"适合定期到访的套餐与会员计划。"}'::jsonb),
  ('Package', '{"en":"Package","zh":"疗程套餐"}'::jsonb, null::jsonb),
  ('Membership', '{"en":"Membership","zh":"会员计划"}'::jsonb, null::jsonb)
) as seed(english_name, name, description)
where existing.name->>'en' = seed.english_name;

-- Package and Membership are child categories of Offer.
insert into public.category (name, parent_id)
select seed.name, offer.id
from (values ('{"en":"Package","zh":"疗程套餐"}'::jsonb), ('{"en":"Membership","zh":"会员计划"}'::jsonb)) as seed(name)
join public.category offer on offer.name->>'en' = 'Offer'
where not exists (
  select 1
  from public.category existing
  where existing.name->>'en' = seed.name->>'en'
);

insert into public.service (name, image, category_id)
select jsonb_build_object('en', seed.service_name, 'zh', seed.service_name_zh), seed.image, category.id from (values
  ('Signature Wellness Collection', 'Relaxation Massage', '舒缓按摩', 'assets/services/default.jpg'),
  ('Signature Wellness Collection', 'Chinese Acupressure', '中式指压', 'assets/services/chinese-acupressure.jpg'),
  ('Signature Wellness Collection', 'Deep Tissue Massage', '深层组织按摩', 'assets/services/default.jpg'),
  ('Signature Wellness Collection', 'Foot Reflexology', '足底反射疗法', 'assets/services/reflexology.jpg'),
  ('Signature Wellness Collection', 'Extra time', '加时', 'assets/services/default.jpg'),
  ('Premium Therapy Collection', 'Lymphatic Drainage Massage', '淋巴引流按摩', 'assets/services/lymphatic-drainage-massage.jpg'),
  ('Premium Therapy Collection', 'Hot Stone Massage', '热石按摩', 'assets/services/hotstone.jpg'),
  ('Premium Therapy Collection', 'extra time', '加时', 'assets/services/default.jpg'),
  ('Membership', 'Annual Membership', '年度会员', 'assets/services/default.jpg'),
  ('Package', '60-mins value pack', '60分钟疗程套餐', 'assets/services/default.jpg'),
  ('Package', '30-mins value pack', '30分钟疗程套餐', 'assets/services/default.jpg')
) as seed(category_name, service_name, service_name_zh, image)
join public.category category on category.name->>'en' = seed.category_name
where not exists (
  select 1
  from public.service existing
  where existing.name->>'en' = seed.service_name
    and existing.category_id = category.id
);

update public.service set image = case
  when lower(name->>'en') like '%reflexology%' then 'assets/services/reflexology.jpg'
  when lower(name->>'en') like '%lymphatic%' then 'assets/services/lymphatic-drainage-massage.jpg'
  when lower(name->>'en') like '%aromatherapy%' or lower(name->>'en') like '%meridian%' then 'assets/services/aromatherapy-meridian-massage.jpg'
  when lower(name->>'en') like '%acupressure%' then 'assets/services/chinese-acupressure.jpg'
  when lower(name->>'en') like '%hot stone%' or lower(name->>'en') like '%hotstone%' then 'assets/services/hotstone.jpg'
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
join public.category category on category.name->>'en' = seed.category_name
join public.service service on service.category_id = category.id and service.name->>'en' = seed.service_name
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
