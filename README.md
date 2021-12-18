# Matrix

Representation of 2D matrix, with directly (get & set) addressable rows and columns
e.g 
```
var m = Matrix(["1","2","3","4","5",6"], rowLength: 2 )

// get:
let row1 = m.row[1]        //  ["3","4"]
let column0 = m.column[0]  //  ["2","4","6"]

// set:
m.column[1] = ["a", "b", "c"]

```


