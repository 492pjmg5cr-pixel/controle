# 📦 Controle de Estoque

App web (HTML, CSS e JavaScript puros, sem servidor) para controlar estoque pelo celular ou computador.

## Funcionalidades

- **Cadastro** de produtos com foto (câmera), preço de varejo, preço de atacado e quantidade.
- **Aba Produtos**: tabela com foto, quantidade (+/−), valor, e botões Editar e Excluir.
- **Exportar Excel**: aba *Estoque* (com fotos e fórmulas) e aba *Atualizações* (histórico de entradas, saídas e edições).
- **Catálogo em PDF** com os produtos selecionados, preços de varejo e atacado, WhatsApp e endereço no rodapé.
- **Flyer** (PNG ou PDF) com os produtos selecionados; textos e cores podem ser criados por IA.
- **Aba Adm** (login): valor pago, margem de lucro, fornecedor e contato, edição na própria tela e Excel do administrador.

## Como usar

Abra o `index.html` no navegador ou, para testar com um servidor local:

```bash
python3 -m http.server 8000
# abra http://localhost:8000
```

## Publicar no GitHub Pages

```bash
git init
git add .
git commit -m "Controle de estoque"
git branch -M main
git remote add origin https://github.com/SEU-USUARIO/estoque-app.git
git push -u origin main
```

No GitHub: **Settings → Pages → Build and deployment → Deploy from a branch → `main` / `/ (root)`**. O endereço será `https://SEU-USUARIO.github.io/estoque-app/`.

## Banco de dados (Supabase)

Os dados ficam num banco Postgres na nuvem, compartilhado entre aparelhos. O navegador (IndexedDB) continua como cópia local.

1. Crie um projeto grátis em [supabase.com](https://supabase.com).
2. No **SQL Editor**, cole o conteúdo de `supabase/schema.sql` e clique em **Run** (cria as tabelas `produtos` e `atualizacoes`).
3. Em **Project Settings → API**, copie a *Project URL* e a chave *anon public* para `SUPABASE_URL` e `SUPABASE_KEY` no `config.js`.
4. Abra o app. Se o banco estiver vazio, os dados que já estavam no aparelho são enviados automaticamente.

Se `SUPABASE_URL`/`SUPABASE_KEY` ficarem vazios, o app funciona só no navegador, como antes. Em caso de falha de conexão, as alterações ficam salvas no aparelho e são enviadas na próxima oportunidade. Edições simultâneas em dois aparelhos: vale a última gravação.

**Segurança:** a chave *anon* fica visível no código público e as políticas do `schema.sql` liberam leitura e escrita para ela. Qualquer pessoa com o endereço do app pode, em tese, ler o valor pago e os fornecedores. Para proteger de verdade, use o Supabase Auth e troque `anon` por `authenticated` nas políticas.

## Configuração

### Senha do administrador

O padrão é usuário `adm` e senha `trocar123`. **Troque antes de publicar:**

1. Abra `gerar-senha.html` no navegador, digite o usuário e a senha desejados e copie o código gerado.
2. Cole o código em `ADM_HASH`, no arquivo `config.js`.

### Flyer com IA (opcional)

No modal do flyer, informe uma chave de API da Anthropic. Ela fica salva só no navegador (localStorage) e é enviada diretamente para a API. Sem chave, o flyer usa um modelo automático com cores sorteadas. O modelo pode ser trocado em `config.js` (`AI_MODEL`).

## Limitações e segurança

- Sem Supabase configurado, os dados ficam só no **navegador do aparelho** (IndexedDB), sem criptografia e sem sincronizar. Exporte o Excel de vez em quando como cópia de segurança.
- O login do administrador roda no navegador. O código do app é público, então ele **não é segurança forte**: serve para esconder a aba de uso casual, não para barrar alguém determinado.
- Não coloque dados sensíveis reais em um repositório público.
- Use uma chave de API apenas em aparelhos de confiança. Ela fica visível para quem tiver acesso ao navegador.

## Tecnologias

[ExcelJS](https://github.com/exceljs/exceljs) (planilhas) e [jsPDF](https://github.com/parallax/jsPDF) (PDF), carregados via CDN.

## Autor

Desenvolvido por **Maicon da Rosa Gonçalves**.

## Licença

MIT. Veja `LICENSE` (preencha seu nome).
