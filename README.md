# Spendly

Aplicativo de **gestão financeira pessoal** focado em controle de gastos por
categoria. MVP minimalista, moderno e direto ao ponto — feito para registrar
despesas e entender, em segundos, **quanto** você gastou, **onde** gastou e em
**quais categorias**.

> O nome `Spendly` é provisório e está centralizado em
> `lib/core/constants/app_constants.dart` (`AppConstants.appName`).

---

## ✨ Funcionalidades

**Etapa 1 — base (concluída):**

- Splash com verificação de autenticação e onboarding
- Onboarding (3 telas) com persistência local
- Login, cadastro e recuperação de senha (Firebase Authentication)
- Criação do perfil do usuário no Firestore
- Criação automática das categorias padrão no cadastro
- Tema claro, escuro e do sistema (persistido)
- Navegação inferior com 4 abas (Início, Gastos, Categorias, Perfil)
- Perfil com dados do usuário, troca de tema e logout
- Regras de segurança do Firestore

**Etapa 2 — gastos e resumos (concluída):**

- Adicionar / editar / excluir gastos (com confirmação)
- Lista de gastos com filtro por dia, semana, mês e período personalizado
- Busca por descrição e agrupamento por data
- Cálculos de resumo (total, quantidade, média, maior categoria)
- Gráfico de rosca de gastos por categoria (fl_chart) com legenda
- Dashboard integrado na Home (total, cards de resumo, gráfico, recentes)
- Categorias personalizadas (criar, editar nome/cor, excluir)
- Total de gastos cadastrados no perfil

---

## 🧱 Stack

| Camada            | Tecnologia               |
| ----------------- | ------------------------ |
| Linguagem         | Dart                     |
| UI                | Flutter + Material 3     |
| Estado            | Flutter Riverpod (3.x)   |
| Navegação         | GoRouter                 |
| Backend           | Firebase Core            |
| Autenticação      | Firebase Authentication  |
| Banco de dados    | Cloud Firestore          |
| Gráficos          | fl_chart                 |
| Datas e moeda     | intl                     |
| IDs locais        | uuid                     |
| Preferências      | shared_preferences       |

---

## 📁 Estrutura de pastas

```text
lib/
  app/
    app.dart          # Widget raiz (MaterialApp.router)
    router.dart       # GoRouter + rotas + redirect de auth
    theme.dart        # Tema claro/escuro (Material 3)
    providers.dart    # Providers base (Firebase, repositórios, prefs)

  core/
    constants/        # app_constants, firestore_constants
    errors/           # app_exception + tradução de erros do Firebase
    utils/            # currency_formatter, date_filter_utils, validators
    widgets/          # app_loading, app_error, empty_state, primary_button,
                      # summary_card, confirm_dialog

  features/
    authentication/   # data (repos) + domain (AppUser) + presentation
    onboarding/       # splash, onboarding + controllers
    home/             # home shell (nav inferior) + dashboard
    expenses/         # (etapa 2)
    categories/       # domain (ExpenseCategory) + presentation
    profile/          # perfil do usuário
    settings/         # tema + configurações

  main.dart
  firebase_options.dart   # gerado por `flutterfire configure`
```

Arquitetura simples **por funcionalidade** (feature-first), com camadas
`data / domain / presentation` quando fazem sentido. Lógica relevante fica em
controllers/repositórios — não em widgets.

---

## 🔥 Configuração do Firebase

O arquivo `lib/firebase_options.dart` vem com **valores placeholder**. O app
compila e o `flutter analyze` passa, mas para conectar ao Firebase em tempo de
execução você precisa gerar suas credenciais reais:

1. Crie um projeto no [console do Firebase](https://console.firebase.google.com).
2. Ative **Authentication → Sign-in method → E-mail/senha**.
3. Crie um banco **Cloud Firestore** (modo produção).
4. Instale as CLIs (uma única vez):

   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   firebase login
   ```

5. Gere as credenciais (sobrescreve `firebase_options.dart`):

   ```bash
   flutterfire configure
   ```

6. Publique as regras e índices:

   ```bash
   firebase deploy --only firestore:rules,firestore:indexes
   ```

---

## ▶️ Como rodar

```bash
flutter pub get
flutterfire configure   # configura o Firebase (ver seção acima)
flutter run
```

## ✅ Comandos úteis

```bash
flutter analyze   # análise estática (deve passar sem issues)
flutter test      # testes unitários
dart format .     # formatação
```

---

## 🗄️ Estrutura do Firestore

Estrutura simples, isolada por usuário (sem coleção global de gastos):

```text
users/{userId}
  name, email, createdAt, updatedAt

  users/{userId}/categories/{categoryId}
    name, color, isDefault, createdAt, updatedAt

  users/{userId}/expenses/{expenseId}
    amount, description, categoryId, categoryName, categoryColor,
    paymentMethod, date, note, createdAt, updatedAt
```

> A senha **nunca** é armazenada no Firestore — autenticação é responsabilidade
> exclusiva do Firebase Authentication.

---

## 🔒 Regras de segurança

Definidas em [`firestore.rules`](./firestore.rules). Garantem que:

- o usuário precisa estar autenticado;
- cada usuário só acessa o próprio documento, gastos e categorias;
- nenhum usuário acessa dados de outro (`request.auth.uid` é validado);
- acesso negado por padrão para qualquer outro caminho.

Índices sugeridos em [`firestore.indexes.json`](./firestore.indexes.json)
(consultas por data, categoria + data e forma de pagamento + data).

---

## ⚠️ Limitações do MVP

Fora de escopo nesta versão: Open Finance, importação bancária, integração com
cartão, leitura de extrato, pagamentos, assinaturas, metas avançadas,
investimentos, receitas complexas, compartilhamento familiar, relatórios em PDF,
IA, notificações push e painel administrativo.

---

## 🚀 Próximas melhorias

- Exportação simples de dados (CSV)
- Edição de nome, troca de senha e exclusão de conta no perfil
- Testes de widget para os fluxos principais
- Paginação na lista de gastos para grandes volumes
- Comparativo entre períodos
