# Pocket

**Where ideas are born** 💡

Pocket é um app iOS para captura rápida de ideias com classificação automática por IA.

## Funcionalidades

### Captura Rápida (< 2 segundos)
- **Widget na tela de bloqueio**: Capture ideias instantaneamente sem desbloquear o telefone
- **Captura por voz**: Fale sua ideia e ela é transcrita automaticamente
- **Captura por texto**: Digite rapidamente quando preferir

### Caixas Inteligentes
Organize suas ideias em caixas com comportamentos diferentes:

| Tipo | Comportamento | Exemplo |
|------|--------------|---------|
| **Notas** | Cada ideia vira uma nota individual | Ideias, Inspirações |
| **Lista** | Ideias são itens de lista | Mercado, Compras |
| **Tarefas** | Ideias viram tasks com checkbox | To-Do, Lembretes |
| **Diário** | Agrupa por data | Diário pessoal |
| **Brainstorm** | Conexão visual entre ideias | Projetos |

### Classificação Automática por IA
- A IA analisa o conteúdo e classifica automaticamente
- Palavras-chave personalizáveis por caixa
- Exemplo: Ao dizer "banana", a IA entende que é um item de mercado

## Arquitetura

```
Pocket/
├── App/
│   ├── PocketApp.swift          # Entry point
│   └── DeepLinkHandler.swift    # Deep links do widget
├── Models/
│   ├── AppState.swift           # Estado global
│   ├── Box.swift                # Modelo de caixa
│   └── Idea.swift               # Modelo de ideia
├── Views/
│   ├── ContentView.swift
│   ├── Home/
│   │   └── HomeView.swift
│   ├── Boxes/
│   │   ├── BoxDetailView.swift
│   │   ├── NewBoxView.swift
│   │   └── EditBoxView.swift
│   ├── Capture/
│   │   └── QuickCaptureView.swift
│   └── Onboarding/
│       ├── OnboardingContainerView.swift
│       └── OnboardingSteps.swift
├── Services/
│   ├── SpeechRecognitionService.swift
│   └── ClassificationService.swift
└── Extensions/
    └── Color+Extensions.swift

PocketWidget/
└── PocketWidget.swift           # Widget de captura rápida
```

## Requisitos

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Configuração

1. Clone o repositório
2. Abra `Pocket.xcodeproj` no Xcode
3. Configure o Team de desenvolvimento
4. Configure o App Group: `group.com.pocket.app`
5. Build e run

## Permissões Necessárias

- **Microfone**: Para captura de áudio
- **Speech Recognition**: Para transcrição de voz

## Widget

O app inclui widgets para:
- **Lock Screen (Circular)**: Ícone com contador de ideias
- **Lock Screen (Rectangular)**: Nome + ação rápida
- **Home Screen (Small)**: Botão de captura
- **Home Screen (Medium)**: Opções de voz e texto

## Tecnologias

- SwiftUI
- SwiftData
- WidgetKit
- Speech Framework
- Natural Language Framework

## Roadmap

- [ ] Integração com OpenAI/Claude para classificação avançada
- [ ] Sincronização iCloud
- [ ] Apple Watch app
- [ ] Siri Shortcuts
- [ ] Exportação para outros apps

## Licença

MIT License
