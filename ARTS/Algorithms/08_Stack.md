# Stack

### Linked Stack

```java
package org.songkun.test;
 
public class LinkedStack {
    private Node head;
    private Node temp;
 
    public LinkedStack() {
    }
 
    public Node pop() {
        if (head == null) {
            return null;
        }
        temp = head;
        head = head.getNext();
        temp.setNext(null);
        return temp;
    }
 
    public void push(int val) {
        if (head == null) {
            head = new Node(val, null);
        }
        temp = head;
        head = new Node(val, temp);
    }
}
```
