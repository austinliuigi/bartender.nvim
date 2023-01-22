# 🍺 Bartender
**bartender.nvim** is a plugin to help you manage your bars

## Concept

### Sections
A section is defined by its background color and location in a bar.

`local section = {}`

### Components
A component is an atomic piece of your statusline. Components are defined by their text and highlights.

`local component = {}`

1. `component.text`: *string*

    String that the component should display

2. `component.highlight`: *string | table*

    1. `component.highlight.name`: *string*

        Name of the highlight group to use for the component

    2. `component.highlight.attributes`: *table* **(optional)**

        Table with the same form as what `nvim_set_hl()` takes.

        If non-nil, a highlight group for `component.text` is created
        with provided attributes. The name of this new highlight group
        if prefixed with config's `highlight_prefix`.

        If nil, a new highlight group is not defined.

    3. `component.highlight.reverse`:

    4. `component.highlight.devicon`:

4. `component.click`: *function*

    Function that is run when you click on the component

## Usage

### Adding Sections

### Adding Components
