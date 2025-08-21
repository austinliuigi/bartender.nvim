# 🍺 bartender.nvim

**bartender.nvim** is a plugin to help you manage your bars (winbar, statusline, tabline, statuscolumn).



## Features

- construct bars from **readable, extendable, composable components**
- configure **different styles for focused and unfocused windows**
- cache components and **only update when necessary**
- automatic **highlight group management**
- **live-reload configuration** during runtime
- only manages bars that are configured



## Concept

Bartender views bars as a collection of components. A component defines the string of characters that get displayed, the highlights those characters should have, and a click handler to run when clicked.

There are three types of components: **static components**, **dynamic components**, and **component groups**.


### Static Component

A **static component** is a table with the following fields:

`[1]`: *string*

- String that the component displays. Any format items (`:h 'statusline'` for winbar, statusline, tabline and `:h 'statuscolumn'` for statuscolumn) can be used.

`hl?`: *string | table | fun(): (string|table)*

- Highlight information of the component.
    - If string, it is the name of the highlight group that the component will be highlighted with. 
    - If table, it will take the same form as what `nvim_set_hl()` takes. The `fg` attribute can take a special value `"transparent"`, which will make it the same color as the bg of the bar it is contained in. Any attribute in the table can be a function that returns a value for the attribute instead of a static value. In this case, the function will be called on every update to get the attribute value.
    - If function, it will be called on every redraw and the return value will be used as the highlight.
    - If nil, then the component will be styled with the default highlights of the bar it is contained in.

`on_click?`: *function(int, int, string, string): -> nil*

- Function that is run when you click on the component. See the "@" item in `:h 'statusline'` for documentation on the arguments passed in.

<!-- TODO: Basic example -->


### Dynamic Component

A **dynamic component** uses a function to generate a component. This function is re-evaluated whenever we need to update the component. This allows for more power as opposed to simple static components:

- component text, highlights, and/or click_handler can *change dynamically*
- component can be *generic*, generating a different component depending on the provided arguments

A dynamic component is a table with the following fields:

`[1]`: *fun(): Component, Events?*

- The function to call to generate the component. This is called a dynamic component provider.

`args?`: *any[] | fun(): any[]*

- The arguments to call the provider with. The arguments types depend on the parameters of the provider. If given as a function, it will be called on every update of the dynamic component, and the return value will be used as the arguments to pass to the provider.

`hl?`: *string | table | fun(): (string|table)*

- Highlights to use for the component, overriding the ones the provider generated. Takes the same form as a static compoenent's `hl` field.


#### Provider

A **dynamic component provider** is a function that dynamic components use to generate components. One provider can be used for multiple dynamic components, and can be called with different arguments from each dynamic component.

###### Parameters

Different providers can have different parameters depending on how it's designed.

###### Return Values

`component`: *Component*

- Component that is generated

`events?`: *string | (string|string[])[]*

- Autocommand events in which to re-evaluate the function and update component. If string, it is the name of the event to update on. If table, it is a list of events or { event, pattern } pairs to update on. An empty table makes the component static (never updates). If nil, component updates on every redraw of the bar.

<!-- TODO: Modified example -->


### Component Group

A **component group** is a simply a list of other components.

Component groups allow you to:

- compose components to create higher level components
- coordinate encapsulated components
- semantically group components

Since component groups are themselves a type of component, they can be contained in other component groups, nesting arbitrarily deeply. In fact, entire bars themselves, e.g. the statusline, is represented as a component group that contains any mix of static components, dynamic components, and component groups.

<!-- TODO: Tabs example -->



## Configuration



## Benchmarks

### No Cache

#### Winbar

```
Benchmark results:
  - 10000 function calls
  - 1002.27 milliseconds elapsed
  - 0.10 milliseconds avg execution time.

Benchmark results:
  - 10000 function calls
  - 874.33 milliseconds elapsed
  - 0.09 milliseconds avg execution time.

Benchmark results:
  - 10000 function calls
  - 844.92 milliseconds elapsed
  - 0.08 milliseconds avg execution time.
```

#### Statusline

```
Benchmark results:
  - 10000 function calls
  - 1023.11 milliseconds elapsed
  - 0.10 milliseconds avg execution time.

Benchmark results:
  - 10000 function calls
  - 996.08 milliseconds elapsed
  - 0.10 milliseconds avg execution time.

Benchmark results:
  - 10000 function calls
  - 1042.82 milliseconds elapsed
  - 0.10 milliseconds avg execution time.
```

#### Tabline

```
Benchmark results:
  - 10000 function calls
  - 646.12 milliseconds elapsed
  - 0.06 milliseconds avg execution time.

Benchmark results:
  - 10000 function calls
  - 614.65 milliseconds elapsed
  - 0.06 milliseconds avg execution time.

Benchmark results:
  - 10000 function calls
  - 584.78 milliseconds elapsed
  - 0.06 milliseconds avg execution time.
```

### Cache

#### Winbar

```
Benchmark results:
  - 10000 function calls
  - 256.78 milliseconds elapsed
  - 0.03 milliseconds avg execution time.

Benchmark results:
  - 10000 function calls
  - 240.58 milliseconds elapsed
  - 0.02 milliseconds avg execution time.

Benchmark results:
  - 10000 function calls
  - 176.01 milliseconds elapsed
  - 0.02 milliseconds avg execution time.
```

#### Statusline

```
Benchmark results:
  - 10000 function calls
  - 277.51 milliseconds elapsed
  - 0.03 milliseconds avg execution time.

Benchmark results:
  - 10000 function calls
  - 280.13 milliseconds elapsed
  - 0.03 milliseconds avg execution time.

Benchmark results:
  - 10000 function calls
  - 290.02 milliseconds elapsed
  - 0.03 milliseconds avg execution time.
```

#### Tabline

```
Benchmark results:
  - 10000 function calls
  - 53.91 milliseconds elapsed
  - 0.01 milliseconds avg execution time.

Benchmark results:
  - 10000 function calls
  - 117.26 milliseconds elapsed
  - 0.01 milliseconds avg execution time.

Benchmark results:
  - 10000 function calls
  - 47.74 milliseconds elapsed
  - 0.00 milliseconds avg execution time.
```
