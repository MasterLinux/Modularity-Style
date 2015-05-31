#Grid system
The 12 column grid system consist of a `.row` and `.column` class and a collection of `.size-#{type}-#{weight}` classes.

There are three types of `size`s
* `small` for phones
* `medium` for tablets 
* `large` for desktops

The `weight` starts at `1` and ends at `12` so `size-small-4` and `size-medium-12` are valid classes to set the weight of a column.

```html
<div class="row">
    <div class="column size-large-4"></div>
    <div class="column size-large-4"></div>
    <div class="column size-large-4"></div>
</div>
```

```html
<div class="row">
    <div class="column size-large-4 size-medium-2 size-small-12"></div>
    <div class="column size-large-4 size-medium-5 size-small-12"></div>
    <div class="column size-large-4 size-medium-5 size-small-12"></div>
</div>
```

#Inputs
###Default
```html
<input value="enter text" />
<input value="disabled" disabled />
```

###Search
A search input must have a `.search` class

```html
<input class="search" />
<input class="search" value="disabled" disabled />
```