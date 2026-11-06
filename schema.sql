-- Banco de dados do Controle de Estoque (Supabase / Postgres)
-- Como usar: Supabase > SQL Editor > New query > cole tudo e clique em Run.
-- Pode ser executado mais de uma vez sem erro.

-- ============ Produtos ============
create table if not exists public.produtos (
  id            text primary key,                 -- gerado pelo app
  nome          text not null check (length(trim(nome)) > 0),
  preco         numeric(12,2) not null default 0 check (preco >= 0),   -- preço de varejo
  preco_atacado numeric(12,2) not null default 0 check (preco_atacado >= 0), -- preço de atacado
  qtd           integer       not null default 0 check (qtd >= 0),
  foto          text,                             -- imagem JPEG em data URL (400x400)
  custo         numeric(12,2) check (custo is null or custo >= 0),     -- valor pago (adm)
  forn          text,                             -- fornecedor (adm)
  fcont         text,                             -- contato do fornecedor (adm)
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- Para bancos criados antes do preço de atacado:
alter table public.produtos add column if not exists preco_atacado numeric(12,2) not null default 0 check (preco_atacado >= 0);

-- ============ Histórico (aba "Atualizações" do Excel) ============
create table if not exists public.atualizacoes (
  id         uuid primary key default gen_random_uuid(),
  produto_id text,                                -- sem FK: o histórico sobrevive à exclusão do produto
  nome       text not null,
  acao       text not null check (acao in ('Cadastro','Edição','Entrada','Saída','Exclusão')),
  qa         integer,                             -- quantidade anterior
  qn         integer,                             -- quantidade nova
  pa         numeric(12,2),                       -- preço anterior
  pn         numeric(12,2),                       -- preço novo
  criado_em  timestamptz not null default now()
);

create index if not exists atualizacoes_criado_em_idx on public.atualizacoes (criado_em);
create index if not exists atualizacoes_produto_idx   on public.atualizacoes (produto_id);

-- ============ atualizado_em automático ============
create or replace function public.set_atualizado_em() returns trigger
language plpgsql as $$
begin
  new.atualizado_em = now();
  return new;
end $$;

drop trigger if exists produtos_atualizado_em on public.produtos;
create trigger produtos_atualizado_em
  before update on public.produtos
  for each row execute function public.set_atualizado_em();

-- ============ Segurança (RLS) ============
alter table public.produtos     enable row level security;
alter table public.atualizacoes enable row level security;

-- ATENÇÃO: estas políticas liberam leitura e escrita para quem tiver a chave "anon"
-- (que fica visível no config.js). Serve para uso pessoal/pequeno. Para proteger de
-- verdade (principalmente valor pago e fornecedor), troque "anon" por "authenticated"
-- e use o login do Supabase Auth.
drop policy if exists produtos_all on public.produtos;
create policy produtos_all on public.produtos
  for all to anon using (true) with check (true);

drop policy if exists atualizacoes_ler on public.atualizacoes;
create policy atualizacoes_ler on public.atualizacoes for select to anon using (true);

drop policy if exists atualizacoes_inserir on public.atualizacoes;
create policy atualizacoes_inserir on public.atualizacoes for insert to anon with check (true);
-- (sem update/delete: o histórico não pode ser alterado pelo app)

grant select, insert, update, delete on public.produtos     to anon;
grant select, insert                 on public.atualizacoes to anon;

-- ============ Tempo real ============
-- Faz o banco avisar todos os aparelhos assim que um produto ou histórico muda.
do $$
begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='produtos') then
    alter publication supabase_realtime add table public.produtos;
  end if;
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='atualizacoes') then
    alter publication supabase_realtime add table public.atualizacoes;
  end if;
end $$;
