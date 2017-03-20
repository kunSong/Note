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

+ `void *calloc(size_t nmemb, size_t size);`给array nmemb元素分配内存

+ `int access(const char *pathname, int mode)`调用的程式能否进入给定的pathname文件，查看权限。

+ `strrchr`locate character in string

+ 当if(指针)，就是判断当前指针是否为空。

+ `struc stat`需要引入头文件`<sys/stat.h>`，这个结构体是用来描述Linux系统文件中的文件属性的结构。
```
int stat(const char *path, struct stat *struct_stat);
int lstat(const char *path,struct stat *struct_stat);
ENOENT：路径名的部分组件不存在，或路径名是空字串
struct stat {
    mode_t     st_mode;      //文件对应的模式，文件，目录等
    ino_t      st_ino;       //inode节点号
    dev_t      st_dev;       //设备号码
    dev_t      st_rdev;      //特殊设备号码
    nlink_t    st_nlink;     //文件的连接数
    uid_t      st_uid;       //文件所有者
    gid_t      st_gid;       //文件所有者对应的组
    off_t      st_size;      //普通文件，对应的文件字节数
    time_t     st_atime;     //文件最后被访问的时间
    time_t     st_mtime;     //文件内容最后被修改的时间
    time_t     st_ctime;     //文件状态改变时间
    blksize_t  st_blksize;   //文件内容对应的块大小
    blkcnt_t   st_blocks;    //伟建内容对应的块数量
};
```

+ `int symlink(const char* oldpath, const char* newpath);`以参数newpath指定的名称来建立一个新的连接到参数oldpath所指定的已存在的文件。

+ `FILE *setmntent(const char *filename, const char *type);`打开一个文件描述符。

+ `strndup`拷贝一个字符串

+ `strlcat`连接字符串

+ `snprintf`保证以null结尾

+ cpp对成员初始化，使用初始化列表，性能上有提升
```
class Device {
    public：
        Device(RecoveryUI* ui) : ui_(ui) {} 
    private:
        RecoveryUI* ui_;
}
```

+ cpp纯虚函数需要子类继承后重写实现不需要virtual关键字，子类实例化的时候声明类型为父类类型，则可以调用子类实现的方法，但是不能调用子类的方法
```
virtual void SetStage(int current, int max) = 0
```

+ `static_cast<float>`将表达式转换为float类型但是没有运行时类型检查来保证转换的安全性

+ libpng读取png流程
```
/* 打开指定png图片文件 */
FILE* fp = fopen(resPath, "rb");
/* 读取sizeof(header)个字节数据 */
byteRead = fread(header, 1, sizeof(header));
/* 检测数据是否为PNG的签名 */ 
int png_sig_cmp(png_bytep buf, png_size_t from, size_t to);
/* 创建png read struct */
*png_ptr = png_create_read_struct(...);
/* 创建info struct*/
*info_ptr = png_create_info_struct(...);
/* 设置错误处理 */
setjmp(png_jmpbuf(*png_ptr));
/* 开始读文件 */
png_init_io(*png_ptr, fp);
/* 库会跳过相应的数据*/
png_set_sig_bytes(*png_ptr, sizeof(header));
/* 获取图片信息 */
png_read_info(*png_ptr, *info_ptr);
/* 调用来查询info_ptr中的信息 */
png_get_IHDR(...);
/* 设置参数 */
png_set_expand_gray_1_2_4_to_8
/* 读完后清除释放分配的内存 */
png_destroy_read_struct(...);
```

+ munmap调用删除指定的地址范围和在这范围内导致远引用地址所产生的违法的内存引用

+ mmap将一个文件或者其它对象映射进内存。文件被映射到多个页上，如果文件的大小不是所有页的大小之和，最后一个页不被使用的空间将会清零。mmap在用户空间映射调用系统中作用很大

+ `vector.emplace_back`和`push_back`都是向容器中添加数据

+ `INLINE`关键字是内联函数，将小函数定义在头文件中，为了减小频繁调用小函数所导致的栈空间不足。

+ 内存地址从低到高地址

+ 有效位从高到低`0x11223344`

+ little-endian
  - 最高有效位落在低地址上`44 33 22 11`

+ big-endian
  - 最低有效位落在高地址上`11 22 33 44`

```
int is_little_endian_a(void){
    unsigned short int flag = 0x4321;
    if(*(unsigned char *)&flag == 0x21){
        return 1;
    } else {
        return 0;
    }
}
```