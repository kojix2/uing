# Table updates and lifetime

[日本語](../guide_ja/table-updates-and-lifetime.html)

## Notify the Model about changes

Changing backing data does not automatically reload a Table. Notify the Model after the relevant operation.

```crystal
# After insertion: new_index is the inserted row number.
rows << "New item"
model.row_inserted(rows.size - 1)

# After changing an existing row.
rows[row] = "Renamed"
model.row_changed(row)

# Use the index from before deletion; delete backing data, then notify.
rows.delete_at(row)
model.row_deleted(row)
```

For several changes, keep backing-data operations and notifications in matching order. Sorting changes every row's mapping, so notify each row with `row_changed` or choose a design that recreates the Model when appropriate.

## Safe destruction order

Do not call `model.free` while a Table still uses the Model. Detach the Table from its parent, destroy it, then free the Model.

```crystal
window.on_closing do
  window.delete(table) # Detach the Table from its window.
  table.destroy       # Destroy Table before its Model.
  model.free
  UIng.quit
  true
end
```

When several Tables share one Model, destroy every Table first. Do not notify a destroyed Model and do not retain `Table::Value` or `Selection` objects outside their callback scopes.

Following this order keeps close-window and data-update logic small and predictable.
