## C++

+ NULL被定义为0;nullptr等价于NULL。

+ `->`是可以是结构体指针指向其成员;可以对象指针调用其方法。

+ C/C++标准库函数定义可以在/usr/include中找到。

+ extern关键字
  - c++解决多态问题用函数名和参数联合起来生成一个中间函数名，为了保持不生成中间函数名就要如下。
  ```
  #ifdef __cplusplus
  extern "C"{
  #endif
  ```
  - 在头文件中定义的函数前加extern表示可能在其他源文件中定义。

+ `time_t time(time_t *__timer)`在头文件`time.h`中表示返回当前时间，可以加timer。

+ `int pipe(int pipefd[2])`创建一个管道来进程间通讯，`pipefd[0]`是读取端，`pipefd[1]`是写入端。

+ `fopen;freopen`打开指定路径文件。模式a是在文件最后append，模式r打开只读文件，stream在文件开头。
```
FILE *fopen(const char *path, const char *mode);
FILE *fdopen(int fd, const char *mode);
FILE *freopen(const char *path, const char *mode, FILE *stream);
```

+ `setbuf`一些打开的stream改变他的buffer。
```
void setbuf(FILE *stream, char *buf);
```

+ STDIN_FILENO;STDOUT_FILENO;STDERR_FILENO是文件描述符，是非负整数。stdin是`File *`类型。

+ `dup2`newfd是目标描述符，oldfd源描述符。目标变成了源的副本。
```
int dup2(int oldfd, int newfd);
eg: dup2(pipe[1], STDOUT_FILENO);
```

+ `getline()`读取整句从stream中，把存储buffer的地址放在*lineptr中。
```
ssize_t getline(char **lineptr, size_t *n, FILE *stream);
```

+ `void *realloc(void *ptr, size_t size);`用来改变已分配空间的ptr指向的内存空间，大小为入参大小，并返回指针，原指针被自动释放。


