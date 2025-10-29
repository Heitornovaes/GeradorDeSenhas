# Gerador de Senhas - Flutter App

Aplicativo móvel desenvolvido em Flutter como exercício prático, com o objetivo de gerar senhas seguras, utilizando autenticação Firebase e armazenamento Cloud Firestore.

## 🚀 Objetivo

Criar um aplicativo Flutter integrado ao Firebase Authentication e Cloud Firestore, que permita o login/registro do usuário, gere senhas seguras através de uma API externa (Safekey API), e exiba uma lista com as senhas geradas pelo usuário autenticado.

## ✨ Funcionalidades Principais

**Autenticação de Usuário:** Sistema completo de Login e Registro utilizando **Firebase Authentication** (Email/Senha).
**Introdução (Onboarding):** Tela de introdução exibida apenas no primeiro uso, com opção para não mostrar novamente (usando **SharedPreferences**).
**Geração de Senhas:**
    * Consumo da API **Safekey** ([https://safekey-api-a1bd9aa97953.herokuapp.com/docs/](https://safekey-api-a1bd9aa97953.herokuapp.com/docs/)) via requisição `POST` com corpo `JSON`.
    * Configuração de parâmetros: tamanho da senha (`Slider`), inclusão de maiúsculas, minúsculas, números e símbolos (`SwitchListTile`).
    * Botão para copiar a senha gerada para a área de transferência.
**Armazenamento Seguro:** As senhas geradas são salvas no **Cloud Firestore**, vinculadas ao ID do usuário autenticado. [cite_start]Um `AlertDialog` solicita um rótulo para cada senha antes de salvar.
 **Listagem e Gerenciamento:**
    * A `HomeScreen` exibe as senhas salvas do usuário em tempo real, utilizando `StreamBuilder`.
    * Funcionalidade para **deletar** senhas individualmente.
    * Exibição de estado de lista vazia.
 **Interface:**
    * Uso de animações **Lottie** na SplashScreen e IntroScreen.
    * Componentes reutilizáveis (ex: `CustomTextField`).
    * Feedback ao usuário com `SnackBar`s e indicadores de carregamento.

## 🛠️ Tecnologias Utilizadas

 **Linguagem:** Dart
**Framework:** Flutter
**Backend:** Firebase
    * Firebase Authentication
    * Cloud Firestore
**Requisições HTTP:** Pacote `http`
**Armazenamento Local:** `shared_preferences`
**Animações:** `lottie`
**UI Auxiliar:** `smooth_page_indicator`, `email_validator`

## 📸 Telas (Screenshots)

![Tela de Splash](./screenshots/1.png)

![Tela de Introdução](./screenshots/2.png)

![Tela de Login](./screenshots/3.png)

![Tela Home (Com Senhas)](./screenshots/5.png)

![Tela de Geração de Senha](./screenshots/4.png)


## ⚙️ Como Executar o Projeto

1.  **Clone o Repositório:**
    ```bash
    git clone [https://github.com/Heitornovaes/GeradorDeSenhas.git]
    cd GeradorDeSenhas
    ```
2.  **Configure o Ambiente Flutter:** Certifique-se de ter o [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado e configurado corretamente no seu PATH.
3.  **Configure o Firebase:**
    * Crie um projeto no [Firebase Console](https://console.firebase.google.com/).
    * Ative os serviços **Authentication** (com provedor Email/Senha) e **Cloud Firestore** (inicie em modo de teste).
    * Instale a FlutterFire CLI: `dart pub global activate flutterfire_cli`
    * Execute `flutterfire configure` na pasta do projeto e siga as instruções para conectar o app ao seu projeto Firebase (isso gerará o arquivo `lib/firebase_options.dart`).
4.  **Instale as Dependências:**
    ```bash
    flutter pub get
    ```
5.  **Execute o App:**
    * Conecte um dispositivo ou inicie um emulador Android/iOS.
    * Execute:
        ```bash
        flutter run
        ```

## 📝 Observações

* Este projeto foi desenvolvido como parte de um exercício acadêmico.
* A API Safekey utilizada para geração de senhas é um serviço externo hospedado no Heroku.
* O arquivo `lib/firebase_options.dart` (contendo as chaves de configuração do Firebase) está intencionalmente excluído do controle de versão via `.gitignore` por motivos de segurança.

---