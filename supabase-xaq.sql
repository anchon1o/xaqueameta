-- Xaque á meta · modo en liña · proxecto Supabase "xogos" · prefixo xaq_
-- Copia TODO este texto no SQL Editor de Supabase e preme Run.

create table if not exists xaq_partidas(
  id text primary key,
  estado jsonb not null,
  version int not null default 1,
  creada timestamptz not null default now(),
  actualizada timestamptz not null default now()
);
create table if not exists xaq_asentos(
  partida text not null references xaq_partidas(id) on delete cascade,
  asento int not null,
  token text not null,
  nome text,
  primary key(partida, asento)
);
create table if not exists xaq_xogadas(
  partida text not null references xaq_partidas(id) on delete cascade,
  rolda int not null,
  asento int not null,
  plan jsonb not null,
  creada timestamptz not null default now(),
  primary key(partida, rolda, asento)
);

-- Seguridade: as táboas de asentos e xogadas non se poden ler directamente
-- (así as xogadas son secretas ata que xogaron todos). Todo pasa polas funcións.
alter table xaq_partidas enable row level security;
alter table xaq_asentos  enable row level security;
alter table xaq_xogadas  enable row level security;
drop policy if exists xaq_partidas_ler on xaq_partidas;
create policy xaq_partidas_ler on xaq_partidas for select to anon using (true);

create or replace function xaq_crear(p_id text, p_estado jsonb) returns boolean
language plpgsql security definer set search_path = public as $$
begin
  insert into xaq_partidas(id, estado) values (p_id, p_estado);
  return true;
exception when unique_violation then return false;
end $$;

create or replace function xaq_unirse(p_id text, p_asento int, p_nome text) returns text
language plpgsql security definer set search_path = public as $$
declare t text := md5(random()::text || clock_timestamp()::text);
begin
  insert into xaq_asentos(partida, asento, token, nome) values (p_id, p_asento, t, p_nome);
  return t;
exception when unique_violation then return null;
end $$;

create or replace function xaq_info(p_id text) returns jsonb
language sql security definer set search_path = public as $$
  select jsonb_build_object(
    'estado', p.estado,
    'version', p.version,
    'asentos', coalesce((select jsonb_agg(jsonb_build_object('a', a.asento, 'nome', a.nome))
                         from xaq_asentos a where a.partida = p_id), '[]'::jsonb),
    'enviadas', coalesce((select jsonb_agg(x.asento) from xaq_xogadas x
                          where x.partida = p_id and x.rolda = (p.estado->>'round')::int), '[]'::jsonb))
  from xaq_partidas p where p.id = p_id
$$;

create or replace function xaq_enviar(p_id text, p_asento int, p_token text, p_rolda int, p_plan jsonb) returns boolean
language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from xaq_asentos where partida = p_id and asento = p_asento and token = p_token) then
    return false;
  end if;
  insert into xaq_xogadas(partida, rolda, asento, plan) values (p_id, p_rolda, p_asento, p_plan)
    on conflict (partida, rolda, asento) do update set plan = excluded.plan, creada = now();
  update xaq_partidas set actualizada = now() where id = p_id;
  return true;
end $$;

-- Devolve as xogadas da rolda só cando xa enviaron todas as persoas (nunca antes)
create or replace function xaq_xogadas_rolda(p_id text, p_rolda int) returns jsonb
language sql security definer set search_path = public as $$
  select case when count(x.*) >= (select count(*) from xaq_partidas p,
                                   jsonb_array_elements(p.estado->'seats') s
                                   where p.id = p_id and (s->>'human')::boolean)
              then jsonb_object_agg(x.asento::text, x.plan) else null end
  from xaq_xogadas x where x.partida = p_id and x.rolda = p_rolda
$$;

create or replace function xaq_gardar(p_id text, p_version int, p_estado jsonb, p_asento int, p_token text) returns boolean
language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from xaq_asentos where partida = p_id and asento = p_asento and token = p_token) then
    return false;
  end if;
  update xaq_partidas set estado = p_estado, version = version + 1, actualizada = now()
    where id = p_id and version = p_version;
  return found;
end $$;

grant execute on function xaq_crear(text, jsonb) to anon;
grant execute on function xaq_unirse(text, int, text) to anon;
grant execute on function xaq_info(text) to anon;
grant execute on function xaq_enviar(text, int, text, int, jsonb) to anon;
grant execute on function xaq_xogadas_rolda(text, int) to anon;
grant execute on function xaq_gardar(text, int, jsonb, int, text) to anon;

-- Opcional, para limpar partidas vellas (máis de 60 días sen moverse):
-- delete from xaq_partidas where actualizada < now() - interval '60 days';
