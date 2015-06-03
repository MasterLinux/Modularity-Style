#Syntax
* `#{}` is used to bind a property or function 
* `.` is equal to `this.` and is a reference to the current scope
* `@` is equal to `context.` and is a reference to to the data context (view model)

#Binding
`<tag attribute="#{property}" />` binds the views `attribute` to the view models `getter` and `setter`.

1. parse template string
2. bind property name to attribute
 
#Template Example
```xml
<?xml version="1.0" ?>
<template dataContext="viewModelName">
    <list items="#{@collectionName}">
        <template>
            <list-item
                    type="file"
                    title="#{.modelPropertyName?:defaultValue}"
                    on-click="#{@functionName()}"/>
        </template>
    </list>
</template>
```
