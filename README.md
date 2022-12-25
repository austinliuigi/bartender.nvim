## Terminology

### Sections
A section is defined by its background color and location.

### Components (table|function)
A component is an atomic piece of your statusline. Without components, your statusline would be empty.

`local component = {}`

1. `component.text`: *string*

    String that the component should display

2. `component.length`: *int (optional)*

    Length of the component. If nil, uses length of component.text

    Should rarely need to be overridden.

3. `component.highlight`: *table*

    1. `component.highlight.name`: *string*

        Name of the highlight group to use for the component

    2. `component.highlight.attributes`: *table (optional)*

        Table with the same form as what `nvim_set_hl()` takes.

        If non-nil, a highlight group for `component.text` is created
        with provided attributes. The name of this new highlight group
        if prefixed with config's `highlight_prefix`.

        If nil, a new highlight group is not defined.

    3. `component.highlight.reverse`:

    4. `component.highlight.devicon`:

4. `component.click`:

    Function that is run when you click on the component
