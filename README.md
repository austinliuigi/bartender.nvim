# 🍺 Bartender

**bartender.nvim** is a plugin to help you manage your bars

## Concept

### Components

A component is an atomic piece of your statusline.

#### Creating Components

A component is simply a function that returns a table with the following keys:

1. `text`: *string*

    String that the component should display

2. `highlight`: *string | table*

    - if the type is a string, it will act as the highlight-group name that this
      component will use for it's highlighting

    - if the type is a table, it with the same form as what `nvim_set_hl()` takes.

        If non-nil, a highlight group for `component.text` is created
        with provided attributes. The name of this new highlight group
        if prefixed with config's `highlight_prefix`.

        If nil, a new highlight group is not defined.

4. `click`: *function -> nil*

    Function that is run when you click on the component


### Sections

A section is a group of components. Sections exist for the following reasons:

1. semantic grouping of components
2. easily setting accent colors
3. lazily changing components

`local section = {}`

## Usage


> Sections and components are evaluated in the context of the window that the
> bar belongs to at the time of evaluation. Bartender stores the window id of
> the active window in `bartender.active_winid`.
