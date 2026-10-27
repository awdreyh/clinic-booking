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
    )
) as seed(name, description)
where not exists (
  select 1
  from public.category existing
  where existing.name = seed.name
);
