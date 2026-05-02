# Imagens e Ícones do Projeto ServiceFlow

## Estrutura de Assets

### Diretório: `/assets/images/`

Este diretório contém todas as imagens utilizadas na aplicação:

#### Já implementadas:
- `logo.png` - Logo da aplicação (150x150px recomendado)

#### Sugeridas para implementação:

**Ícones de ações (24x24px ou 32x32px):**
- `icon_add.png` - Ícone para adicionar/criar novos itens
- `icon_edit.png` - Ícone para editar registros
- `icon_delete.png` - Ícone para excluir (vermelho)
- `icon_deactivate.png` - Ícone para desativar (laranja)
- `icon_activate.png` - Ícone para ativar (verde)
- `icon_save.png` - Ícone para salvar
- `icon_cancel.png` - Ícone para cancelar
- `icon_search.png` - Ícone para buscar
- `icon_filter.png` - Ícone para filtrar

**Ícones de status (16x16px):**
- `status_active.png` - Status ativo (círculo verde)
- `status_inactive.png` - Status inativo (círculo cinza)
- `status_sync.png` - Status sincronizado
- `status_pending.png` - Status pendente

**Ícones de categorias (48x48px):**
- `category_clients.png` - Categoria clientes
- `category_services.png` - Categoria serviços
- `category_orders.png` - Categoria ordens de serviço
- `category_technicians.png` - Categoria técnicos

**Ilustrações de estado vazio (128x128px):**
- `empty_clients.png` - Ilustração para lista de clientes vazia
- `empty_services.png` - Ilustração para lista de serviços vazia
- `empty_orders.png` - Ilustração para lista de ordens vazia
- `no_data.png` - Ilustração genérica para dados vazios

## Como usar as imagens:

### 1. Adicionando ao pubspec.yaml (já configurado):
```yaml
flutter:
  assets:
    - assets/images/
```

### 2. Usando nos widgets customizados:
```dart
// Em botões
CustomPrimaryButton(
  text: 'Adicionar',
  icon: AppIcons.add, // ou Image.asset('assets/images/icon_add.png')
  onPressed: () {},
)

// Em cards de estado vazio
CustomEmptyStateCard(
  icon: AppIcons.peopleOutline,
  // ou usar imagem personalizada:
  // iconWidget: Image.asset('assets/images/empty_clients.png', width: 80),
)
```

### 3. Criando imagens personalizadas:
- Use ferramentas como Figma, Sketch, ou GIMP
- Mantenha consistência de cores com o tema da app
- Cores principais: Azul (#2196F3), Verde (#4CAF50), Laranja (#FF9800), Vermelho (#F44336)
- Prefira PNG com fundo transparente
- Para ícones, use tamanhos múltiplos (16px, 24px, 32px, 48px)

## Otimização:

- Mantenha arquivos leves (prefira PNG otimizado)
- Use SVG quando possível para escalabilidade
- Considere versões @2x e @3x para diferentes densidades de tela

## Alternativamente:

Se não quiser criar imagens personalizadas, os componentes já estão configurados para usar `AppIcons` (ícones do Material Design) que funcionam perfeitamente e mantêm a consistência visual.