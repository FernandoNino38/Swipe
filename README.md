<div align="center">

# 📸 Swipe
### Triagem Inteligente e Limpeza de Galeria de Fotos

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Design](https://img.shields.io/badge/Design-Samsung%20One%20UI%209-0072DE?style=for-the-badge&logo=samsung&logoColor=white)](https://developer.samsung.com/one-ui)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)

<p align="center">
  <b>Organize, mantenha ou descarte fotos da sua galeria com rapidez e fluidez através de gestos intuitivos.</b><br>
  Construído com base na estética premium <b>Samsung One UI 9</b>, processamento 100% offline e física de cards interativa.
</p>

</div>

---

## 🌟 Visão Geral

O **Swipe** é um aplicativo móvel voltado para a organização e limpeza de galerias locais de imagens. Inspirado na mecânica fluida de deslizar cards, o aplicativo permite que o usuário tome decisões rápidas e prazerosas sobre cada foto:

- 👉 **Deslize para a Direita**: Manter a foto na galeria.
- 👈 **Deslize para a Esquerda**: Marcar para exclusão (Soft-Delete para revisão).
- 👆 **Toque em Favoritar**: Adicionar a foto instantaneamente à coleção de Favoritos.
- ↩️ **Desfazer (Undo)**: Reverter instantaneamente a última decisão com animação física de reentrada.

---

## ✨ Recursos Principais

### 🎨 Visual Inspirado na Samsung One UI 9
- **Cápsula Flutuante Unificada (*Now Island / Floating Capsule*)**: Barra de ações com efeito de vidro fosco translúcido (`BackdropFilter` gaussian blur), contornos sutis e botões squircle ergonomicamente posicionados para uso com uma mão.
- **Geometria Squircle & Superellipse**: Cartões com raios pronunciados de **34dp**, oferecendo harmonia visual e acabamento refinado.
- **Paleta de Cores Signature**: Samsung Electric Blue (`#0072DE`), Emerald Mint (`#2AC06D`), Coral Red (`#FA5252`) e Rose Pink (`#FF3366`).
- **Modo Escuro AMOLED Profundo**: Preto absoluto (`#0A0C10`) com superfícies em cinza carvão (`#161922`), otimizando o consumo de bateria em telas OLED.

### 🃏 Baralho de Fotos com Física de Gestos
- Transição contínua com escala responsiva e rotação angular proporcional à velocidade do toque.
- Indicadores laterais coloridos (verde/vermelho) que reagem em tempo real à intensidade do movimento.
- Pílulas translúcidas de metadados na base da imagem (data, hora, tamanho e resolução).

### 🗂️ Seletor de Álbuns & Lotes Personalizados
- **Seleção de Pastas**: Escolha qualquer pasta do dispositivo (Câmera, WhatsApp, Downloads, etc.).
- **Tamanho do Lote**: Defina quantas fotos deseja triar por sessão (ex: 20, 40, 60, 100 fotos ou o álbum completo).
- **Critérios de Ordenação**: Ordene por mais recentes, mais antigas ou maiores arquivos primeiro para liberar espaço rapidamente.

### 🧠 Memória Persistente de Fotos Mantidas
- O aplicativo armazena localmente o histórico das fotos que você já decidiu manter, garantindo que elas não voltem a aparecer em sessões futuras.
- Opção para alternar a exibição ou resetar o histórico a qualquer momento nas configurações.

### 🗑️ Grade de Confirmação e Segurança (Hard-Delete)
- Fotos marcadas para descarte são agrupadas em uma grade de revisão antes de qualquer ação irreversível.
- Exibição em tempo real do volume exato de armazenamento que será liberado (MB/GB).
- Opção de desmarcar itens individualmente ou confirmar a exclusão definitiva de uma só vez.

### 🔒 100% Offline & Privacidade Total
- Nenhum dado ou foto sai do seu smartphone. Sem logins obrigatórios, sem coleta de telemetria e sem dependência de servidores em nuvem.

### 🌐 Suporte Bilíngue
- Alternância rápida entre **Português** e **Inglês** com um único toque na barra superior, sem necessidade de reiniciar o app.

---

## 🛠️ Tecnologias Utilizadas

- **Framework**: [Flutter](https://flutter.dev) (Dart 3.x)
- **Gerenciamento de Estado**: [Provider](https://pub.dev/packages/provider)
- **Acesso à Mídia Local**: [photo_manager](https://pub.dev/packages/photo_manager)
- **Persistência Local**: [shared_preferences](https://pub.dev/packages/shared_preferences)
- **Feedback Háptico**: HapticFeedback nativo do Flutter
- **Efeitos Visuais**: `BackdropFilter` (Blur), `InkSparkle` (Material 3 Ripple), `Hero Animations`

---

## 📂 Estrutura do Projeto

```text
lib/
├── core/
│   ├── localization/         # Strings e internacionalização (PT/EN)
│   ├── services/             # Serviços de mídia e histórico persistente
│   └── theme/                # Tokens de design e tema Samsung One UI 9
├── domain/
│   ├── controllers/          # Controller de triagem e regras de negócio
│   └── models/               # Modelos de dados e ações
└── presentation/
    ├── screens/              # Telas (Deck principal, Favoritos, Lixeira, Detalhes)
    └── widgets/              # Componentes (Card, Cápsula Flutuante, Seletor de Álbum)
```

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.13.0)
- [Android Studio](https://developer.android.com/studio) ou VS Code com extensões Flutter/Dart
- Dispositivo Android (ou emulador) com Android 8.0+

### Instalação

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/FernandoNino38/Swipe.git
   cd Swipe
   ```

2. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

3. **Execute os testes automatizados:**
   ```bash
   flutter test
   ```

4. **Inicie o aplicativo em modo debug:**
   ```bash
   flutter run
   ```

5. **Gere o APK de produção:**
   ```bash
   flutter build apk --release
   ```
   *O APK compilado estará em `build/app/outputs/flutter-apk/app-release.apk`.*

---

## 📄 Licença

Este projeto está sob a licença **MIT** - consulte o arquivo [LICENSE](LICENSE) para obter mais detalhes.

---

<div align="center">
  Desenvolvido com carinho e foco em usabilidade.
</div>
