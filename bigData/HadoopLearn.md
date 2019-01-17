---
title: Hadoop Fundamentals
book: Hadoop Definition Guide
tags: []
---

*在古时候，人们用牛来拉重物。当一头牛拉不动一根圆木时，人们从来没有考虑过要培育更强壮的牛。
同理，我们也不该想方设法打造超级计算机，而应该千方百计综合利用更多计算机来解决问题。*
--Grace Hopper


# 初始Hadoop

## 1.1 数据！数据！

+ 大数据胜于好算法
+ 不论算法有多牛，基于小数据的推荐效果往往都不如基于大量可用数据的一般算法的推荐效果

## 1.2 数据的存储与分析

1. 如果我们有100个硬盘，每个硬盘存储1%的数据，并行读取，那么不到两分钟就可以读完所有数据
2. Hadoop 为我们提供了一个可靠的共享存储和分析系统。
3. HDFS(Hadoop Distributed File System) 实现数据的存储。
4. MapReduce 实现数据的分析和处理。
5. HDFS 和 MapReduce 是它的核心价值。

## 1.3 相较于其他系统的优势

MapReduce 是一个批量查询处理器，能够在合理的时间范围内处理针对整个数据集的动态查询。

### 1.3.1 关系型数据库管理系统

关系型数据库和MapReduce的比较

# 关于MapReduce

## 2.2 使用 Unix 工具来分析数据

awk 循环遍历按年压缩的数据文件

### 2.3.1 map & reduce

简单介绍了map和reduce的工作原理

### 2.3.2 Java MapReduce

+ Mapper 通过实现 `Mapper<K1,V1,K2,V2>` 接口来实现map函数

```java
public static class TokenizerMapper 
       extends Mapper<Object, Text, Text, IntWritable>{
    
    private final static IntWritable one = new IntWritable(1);
    private Text word = new Text();

    public void map(Object key, Text value, Context context
                    ) throws IOException, InterruptedException {
      StringTokenizer itr = new StringTokenizer(value.toString());
      while (itr.hasMoreTokens()) {
        word.set(itr.nextToken());
        context.write(word, one);
      }
    }
}
```
  1. K1-输入键;V1-输入值;K2-输出键;V2-输出值;
  2. Maps 是一个独立的任务, 去以输入为键值对的记录转化为，以键值对的中间件(intermediate)，
记录中间件(intermediate)记录的类型不需要和输入记录类型相符, 但是需要和Reducer的输入类型相符，
Map-Reduce 框架产生一个map任务通过Job以InputFormat形式产生InputSplit
Mapper继承自JobConfigurable，通过confiure(JobConf)来初始化自己
  3. map
  4. setOutputKeyComparatorClass 通过给定的比较器来控制给到Reducer数据的顺序，
也可以模拟作为Reducer时Secondary sort on values...setOutputValueGroupingComparator
  5. Partitioner 分区，通过自定义的Partitioner来控制被归类的Mapper输出结果被分配到Reducer
如果有多个reduce任务, 每个map任务会针对输出进行分区，即为每个reduce任务建一个分区，
默认patitioner通过哈希函数来分区，很高效
  6. Combiner#setCombinerClass 通过Combiner完成对中间件(intermediate)输出结果的本地
聚集来帮助减少数据从Mapper到Reducer的传输量
  7. SequenceFile 中间件(intermediate)或者归类的输出值会被存储为SequenceFiles，
可以通过CompressionCodec来进行压缩
  8. /org/apache/hadoop/mapred/JobConf.html#ReducerNone>zeroreduces
当数据处理完全可以并行，无需混洗时，可能没有Reduce任务，Mapper会把结果直接写到FileSystem
没有根据键值归类
  9. `org.apache.hadoop.io`#
LongWritable ~ Long(Java);IntWritable ~ Integer(Java);Text ~ String(Java);

+ Reducer 通过实现 `Reducer<K1,V1,K2,V2>` 接口实现reduce函数

```java
public static class IntSumReducer 
       extends Reducer<Text,IntWritable,Text,IntWritable> {
    private IntWritable result = new IntWritable();

    public void reduce(Text key, Iterable<IntWritable> values, 
                       Context context
                       ) throws IOException, InterruptedException {
      int sum = 0;
      for (IntWritable val : values) {
        sum += val.get();
      }
      result.set(sum);
      context.write(key, result);
    }
}
```

  1. Reducer功能是一个将分享key值的中间件(intermediate)数据削减为小集合的数据
  2. 通过三个phase
    - Shuffle: 每个Reducer会通过HTTP获取(fetch)相关的Mapper输出的partition，
因为每个reduce任务可能来自许多map任务
    - Sort: 因为不同Mapper输出可能会有相同的key，根据keys归类Reducer的输入
    - Shuffle和Sort是同时发生的
    - SeconderSort: setOutputValueGroupingComparator
    - 在Reduction前会有对键的不同的相等规则，中间件(intermediates)，
增加比较器来归类~setOutputKeyComparatorClass
  3. 通过OutputCollector#collect(Object, Object)写到FileSystem

+ Job

```java
public static void main(String[] args) throws Exception {
    Configuration conf = new Configuration();
    String[] otherArgs = new GenericOptionsParser(conf, args).getRemainingArgs();
    if (otherArgs.length < 2) {
      System.err.println("Usage: wordcount <in> [<in>...] <out>");
      System.exit(2);
    }
    Job job = Job.getInstance(conf, "word count");
    job.setJarByClass(WordCount.class);
    job.setMapperClass(TokenizerMapper.class);
    job.setCombinerClass(IntSumReducer.class);
    job.setReducerClass(IntSumReducer.class);
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(IntWritable.class);
    for (int i = 0; i < otherArgs.length - 1; ++i) {
      FileInputFormat.addInputPath(job, new Path(otherArgs[i]));
    }
    FileOutputFormat.setOutputPath(job,
      new Path(otherArgs[otherArgs.length - 1]));
    System.exit(job.waitForCompletion(true) ? 0 : 1);
}
```

  1. 通过 setJarByClass 打包JAR文件，可以在Hadoop集群上发布这个文件
  2. FileInputFormat.addInputPath 指定输入数据路径
  3. FileOutputFormat.setOutputPath 指定输出数据路径
  4. setOutputKeyClass/setOutputValueClass 指定map&reduce函数输出类型
  5. setMapOutputKeyClass/setMapOutputValueClass 指定map函数输出类型
  6. waitForCompletion 提交作业等待完成

#### 2.3.2.1 运行测试

1. `bash export HADOOP_CLASSPATH=...`
2. 通过添加环境变量用于添加应用程序的路径
`hadoop WordCount input/ncdc/sample.txt output`

## 2.5 Hadoop Streaming

+ Hadoop提供了 MapReduce 的 API，允许运行非Java开发的map&reduce函数

```
hadoop jar $HADOOP_INSTALL/contrib/streaming/hadoop-* -stream.jar\
-input input/ncdc/sample.txt \
-mapper ch02/src/main/ruby/max_temperature_map.rb \
-reduce ch02/src/main/ruby/max_temperature_reduce.rb
```

# Hadoop 分布式文件系统

# 3.2 HDFS概念

### 3.2.1 数据块

+ Hadoop 数据块(block) 默认128MB，主要是为了最小化寻址开销
+ 对于分布式系统块进行抽象好处
  1. 一个文件的大小可以大于网络中任意一个磁盘的容量，文件的所有块并不需要存储在同一个磁盘上，
它们可以利用集群上的任意一个磁盘进行存储
  2. 使用块而非整个文件作为存储单元，大大简化了存储子系统的设计，块的大小是固定的，
因此计算单个磁盘能存储多少个块就相对容易
  3. 块还非常适合用于数据备份进而提供数据容错能力和提高可用性，默认3个块复制，可确保块，
磁盘或机器发生故障时数据不会丢失`hadoop fsck / -files -blocks`
+ 如果写不满一个块就是一个块，如果写满一个块再增加一个新块

```
FSCK started by thundersoft (auth:SIMPLE) from /127.0.0.1 
for path / at Tue May 03 18:57:08 CST 2016
/ <dir>
/user <dir>
/user/Hadoop.pdf 144592354 bytes, 2 block(s):  OK
0. BP-353936892-10.233.68.153-1461751350909:blk_1073741828_1004 len=134217728 repl=1
1. BP-353936892-10.233.68.153-1461751350909:blk_1073741829_1005 len=10374626 repl=1

/user/core-site.xml 887 bytes, 1 block(s):  OK
0. BP-353936892-10.233.68.153-1461751350909:blk_1073741825_1001 len=887 repl=1

/user/output <dir>
/user/output/_SUCCESS 0 bytes, 0 block(s):  OK

/user/output/part-r-00000 982 bytes, 1 block(s): 
Under replicated BP-353936892-10.233.68.153-1461751350909:blk_1073741827_1003. 
Target Replicas is 3 but found 1 replica(s).
0. BP-353936892-10.233.68.153-1461751350909:blk_1073741827_1003 len=982 repl=1
```

### 3.2.2 namenode & datanode

+ **namenode:** 管理文件系统的命名空间，维护文件系统树及整个树的所有文件和目录，命名空间镜像
文件和编辑日志文件，以及每个文件中各个块所在的数据节点信息
+ **datanode:** 文件系统的工作节点，定期向namenode发送它们所在存储的块的列表
+ 防止namenode服务机器损坏，文件系统上所有文件丢失的两种机制
  1. 将持久状态写入本地磁盘的同时，写入一个远程挂载的网络文件系统(NFS)
  2. 运行辅助的namenode，定期通过编辑日志合并命名空间镜像，为了防止编辑日志过大。辅助
namenode在另一台物理计算机上运行，并在发生故障时启用，需要大量CPU时间和与namenode相同的内存
来执行合并操作。但是滞后与主节点，会从NFS里元数据复制到辅助namenode并作为新的namenode运行。

### 3.2.3 联邦HDFS

### 3.2.4 HDFS的高可用性

## 3.3 命令行接口

+ 通过在core-site.xml中配置的fs.default.name, 设置为hdfs://localhost:9000可以在本机上
运行一个HDFS系统。具体可以看Instapaper中hadoop2.7.2单机、伪分布、分布式安装指导。
dfs.replication: 默认设置为3复本，可以自行设置为1，在单独一个datanode上运行时，无法复制到
3个datanode上，会有复制不足的警告。

+ 命令
  1. 首先需要新建一个home目录 `hadoop fs -mkdir /user `
  2. 将一个文件从本地拷贝到运行在localhost上的文件系统中 
`hadoop fs -copyFromLocal /input/core-site.xml (hdfs://localhost:9000/)user/ `
  3. 帮助命令 `hadoop fs -help`

## 3.4 Hadoop文件系统

+ **Java抽象类:** `org.apche.hadoop.fs.FileSystem` 定义个Hadoop中一个文件系统接口
+ **显示本地文件系统:** `hadoop fs -ls file:/// `
+ **Http访问HDFS:** 客户端通过使用 DistributedFileSystemAPI 访问 HDFS 由于namenode
内嵌web服务器端口号在50070上提供服务，目录列表以XML或JSON格式存储，并且文件数据由datanode
的web服务器50075上以数据流的形式传输

## 3.5 JAVA 接口

+ Java识别Hadoop URL需要额外的处理
  1. Hadoop继承Java URL框架，仍然是调用setURLStreamHandlerFactory方法。
  2. 以下三个文件分别实现和继承自:
    - URLStreamHandlerFactory接口
    - URLStreamHandler抽象类
    - URLConnection抽象类

```
./hadoop-common-project/hadoop-common/src/main/java/org/apache/hadoop/fs/
FsUrlStreamHandler.java
./hadoop-common-project/hadoop-common/src/main/java/org/apache/hadoop/fs/
FsUrlStreamHandlerFactory.java
./hadoop-common-project/hadoop-common/src/main/java/org/apache/hadoop/fs/
FsUrlConnection.java
```

```java
/** URL.java 设置UrlStreamHandlerFactory */
URL.setURLStreamHandlerFactory(new FsUrlStreamHandlerFactory());

/** FsUrlStreamHandlerFactory.java 根据protocol，创建UrlStreamHandler */
@Override
public java.net.URLStreamHandler createURLStreamHandler(String protocol) {
    FileSystem.getFileSystemClass(protocol, conf);
    if (protocols.get(protocol)) {
      return handler;
    } else {
      // FileSystem does not know the protocol, let the VM handle this
      return null;
    }
}

/** FsUrlStreamHandler.java 创建FsUrlConnection */
@Override
protected FsUrlConnection openConnection(URL url) throws IOException {
    return new FsUrlConnection(conf, url);
}

/** FsUrlConnection.java 改写了connect()在方法，通过FileSystem定义is */
@Override
public void connect() throws IOException {
    try {
      FileSystem fs = FileSystem.get(url.toURI(), conf);
      is = fs.open(new Path(url.getPath()));
    } catch (URISyntaxException e) {
      throw new IOException(e.toString());
    }
}

@Override
public InputStream getInputStream() throws IOException {
    if (is == null) {
      connect();
    }
    return is;
}

/** URL.java URL对象调用 */
public final InputStream openStream() throws java.io.IOException {
  return openConnection().getInputStream();
}

static {
  URL.setURLStreamHandlerFactory(new FsUrlStreamHandlerFactory());
}

  public static void main(String[] args) {
    String url = "hdfs://localhost:9000/user/core-site.xml";
    try {
      InputStream is = new URL(url).openStream();
      IOUtils.copyBytes(is, System.out, 4096, false);
      is.close();
    } catch (IOException e1) {
      // TODO Auto-generated catch block
      e1.printStackTrace();
    }
  }
```

+ 另一种方案，因为有时应用中不能设置 URLStreamHandlerFactory，不通过URL，直接获取
FileSystem对象，然后实现connect()方法，直接读取操作

```java
  public static void main(String[] args) {
    Configuration conf = new Configuration();
    String uri = "hdfs://localhost:9000/user/core-site.xml";
    try {
      FileSystem fs = FileSystem.get(
          new URI(uri)/** URI.create(uri)*/, 
          conf);
      FSDataInputStream fis = fs.open(new Path(uri), 4096);
      IOUtils.copyBytes(fis, System.out, 4096, false);
      fis.close();
    } catch (IOException | URISyntaxException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }
  }
```

+ FileSystem 通用的文件系统API

```
./hadoop-common-project/hadoop-common/src/main/java/org/apache/hadoop/fs/
FileSystem.java
```

```java
/** 获取FileSystem实例的静态工厂方法 */
public static FileSystem get(final URI uri) throw IOException;
public static FileSystem get(final URI uri, final Configuration conf) throw IOException;
public static FileSystem get(final URI uri, final Configuration conf, final String user) 
throw IOException;

/** 获取FSDataInputStream对象，后者默认缓冲为4k */
public abstract FSDataInputStream open(Path f, int bufferSize) throws IOException;
public FSDataInputStream open(Path f) throws IOException {
    return open(f, getConf().getInt("io.file.buffer.size", 4096));
}

/** 获取FSDataOutputStream对象，可以增加Progressable progress来回调进度*/
public FSDataOutputStream create(Path f) throws IOException {
    return create(f, true);
}

/** 通知datanode写入进度 */
pulic interface Progressable {
    public void progress();
}

/** 在文件末尾添加 */
public FSDataOutputStream append(Path f) throws IOException {

}

/** 创建目录 */
public boolean mkdirs(Path f) throws IOException {
    return mkdirs(f, FsPermission.getDirDefault());
}

/** 获取文件或目录的FileStatus状态 */
public abstract FileStatus getFileStatus(Path f) throws IOException;

/** 判断文件是否存在 */
public boolean exists(Path f) throws IOException {
}

/** 列出目录中的内容，还有好几个此方法的重载 */
public abstract FileStatus[] listStatus(Path f) throws FileNotFoundException, IOException;

/** 通过通配符来进行对一系列目录或文件状态的查询 */
public FileStatus[] globStatus(Path pathPattern, PathFilter filter) throws IOException {
}

/** 永久删除文件，recursive为true非空文件和目录会被删除 */
public abstract boolean delete(Path f, boolean recursive) throws IOException;
```

+ FileUtil 工具类

```
./hadoop-common-project/hadoop-common/src/main/java/org/apache/hadoop/fs/
FileUtil.java
```

```java
/** 可以将FileStatus数组转换成Path数组 */
public static Path[] stat2Paths(FileStatus[] stats);
```

+ FileStatus 文件长度，块大小，复本，修改时间，所有者信息，权限

```
./hadoop-common-project/hadoop-common/src/main/java/org/apache/hadoop/fs/
FileStatus.java
```

+ Configuration 封装客户端和服务器的配置 Configured implements Configurable

```
./hadoop-common-project/hadoop-common/src/main/java/org/apache/hadoop/conf/
Configured.java
./hadoop-common-project/hadoop-common/src/main/java/org/apache/hadoop/conf/
Configurable.java
./etc/hadoop/core-site.xml
```

+ FSDataInputStream extends DataInputStream implements Seekable, PositionedReadable

```
./hadoop-common-project/hadoop-common/src/main/java/org/apache/hadoop/fs/
FSDataInputStream.java
```

```java
read(...)
readFully(...)
seek()
// 线程安全的，并不是为并发访问设计，需要多个实例，并且seek()方法开销很大
```

+ FSDataOutputStream extends

```
./hadoop-common-project/hadoop-common/src/main/java/org/apache/hadoop/fs/
FSDataOutputStream.java
```

+ IOUtils 读写的封装

```
./hadoop-common-project/hadoop-common/src/main/java/org/apache/hadoop/io/IOUtils.java
```

```java
/** true/false 控制流关不关 */
IOUtils.copyBytes(is, System.out, 4096, false);

  public static void copyBytes(InputStream in, OutputStream out, int buffSize) 
    throws IOException {
    PrintStream ps = out instanceof PrintStream ? (PrintStream)out : null;
    byte buf[] = new byte[buffSize];
    int bytesRead = in.read(buf);
    while (bytesRead >= 0) {
      out.write(buf, 0, bytesRead);
      if ((ps != null) && ps.checkError()) {
        throw new IOException("Unable to write to output stream.");
      }
      bytesRead = in.read(buf);
    }
  }
```

## 3.6 数据流

### 3.6.1 剖析文件读取

+ DistributedFileSystem extend FileSystem

```
./hadoop-hdfs-project/hadoop-hdfs/src/main/java/org/apache/hadoop/hdfs/DistributedFileSystem.java
```

+ 实现了FileSystem抽象的open函数，利用FileSystemLinkResolver进行跨多个FileSystem的操作，实现了doCall和next方法

```java
  @Override
  public FSDataInputStream open(Path f, final int bufferSize)
      throws IOException {
    statistics.incrementReadOps(1);
    Path absF = fixRelativePart(f);
    return new FileSystemLinkResolver<FSDataInputStream>() {
      @Override
      public FSDataInputStream doCall(final Path p)
          throws IOException, UnresolvedLinkException {
        final DFSInputStream dfsis =
          dfs.open(getPathName(p), bufferSize, verifyChecksum);
        return dfs.createWrappedInputStream(dfsis);
      }
      @Override
      public FSDataInputStream next(final FileSystem fs, final Path p)
          throws IOException {
        return fs.open(p, bufferSize);
      }
    }.resolve(this, absF);
  }
```

  1. DistributedFileSystem 调用open()方法打开希望读取的文件，RPCs调用namenode，确定文件起始几个块的位置
  2. namenode会返回存有这几个块复本的datanode地址，根据网络拓扑它们与客户端之前的距离排序
  3. 如果客户端本身就是一个datanode，如在一个MapReduce中，并保存有相应的数据块复本时，该节点会从本地datanode读取数据
  4. DistributedFileSystem返回可定位的FSDataInput封装DFSInputStream对象管理着 datanode 和 namenode 的 I/O
  5. 存储着文件起始几个块的datanode地址DFSInputStream会连接到最近的datanode，调用read()方法，顺序读取，
到达末端关闭并为一个数据块寻找最好的datanode，对客户端是透明的
  6. 如果有故障datanode 或数据不完整，会尝试下一个最近的数据块，并会记录此损坏的datanode对后须数据块不进行重试，
DFSInputStream会对从这个数据块传送过来的数据进行checksums验证，如果坏的数据块被发现，
会读取其他datanode或读取其复本并通知namenode
  7. namenode告知客户端每个块中最佳的datanode并让客户端直接连接到该datanode检索数据。
  8. namenode是在内存中，所以高效，无需响应数据请求，只需要响应块位置请求。

### 3.6.2 剖析文件写入

1. DistributedFileSystem 调用create()方法新建文件，也是对namenode创建一个RPC调用，此时没有响应的数据块
2. 各种检查确保此文件不存在并且有新建文件的权限，否则会抛出异常IOException
3. DistributedFileSystem返回FSDataOutputStream对象封装一个DFSoutPutStream管理着 datanode 和 namenode 的 I/O
4. DFSOutputStream将数据包分成一个个写入内部队列，data queue
5. DataStreamer处理数据对列，根据datanode列表要求namenode分配新块来存储数据复本，datanode列表形成一个管道默认复本为3，
3个datanode在管道中
6. DataStreamer会将数据包挨个传送到1，2，3datanode
7. DFSOutputStream同样也维护了一个数据对列来等待datanode收到确认回执，ack queue，收到确认回执后会将数据包从队列中删除
8. 写入数据出错，关闭管线确保队列中的所有数据包都添加回数据队列最前端，保证故障节点下游datanode不会漏掉任何一个数据包。
为存储在另一个正常datanode的当前数据块指定一个新的标识，以便datanode恢复后可以删除存储的部分坏的数据块。
从管线中删除故障数据节点并且把余下的数据块写入管线中另外两个正常的datanode，如果namenode注意到块复本量不足，
会在另一个节点上创建一个新的复本。
9. 只要dfs.replication.min默认为1，就会成功不管有多少datanode错误，最后会异步复制到其他datanode直到dfs.replicaion默认为3
10. close() 将所有剩余数据包写入datanode管线，等待确认，进行最小量的数据块复制

### 3.6.3 一致模型

+ 当创建一个新的文件时，文件是立即可见
+ 当写入数据时，文件长度仍热为0， 总之，当前正在写入的块对其他的reader不可见
+ FSDataOutputStream会调用sync()方法进行强行同步，就对其他的reader可见了，Hadoop-2.7.2 使用 hsync()
+ 但是sync会产生额外开销，所有适度使用sync()，对数据鲁棒性和吞吐量有所取舍

## 3.7 Flume & Sqoop 导入数据

+ Flume 是一个将大规模流数据导入HDFS的工具
+ Sqoop 是组织将白天生产的数据库在晚间导入Hive数据仓库中进行分析 link ch15

## 3.8 distcp 并行复制

+ 并行复制命令，在相同版本的Hadoop下使用，否则会不兼容hdfs协议
`hadoop distcp hdfs://namenode1/for distcp hdfs://namenode2/bar `

+ 如果不同版本
`hadoop distcp webhdfs://namenode1:50070/for webhdfs://namenode2:50070/bar `

+ 本地拷贝到HDFS
`hadoop distcp file:///home/thundersoft/sk/Book/ hdfs://localhost:9000/user/book `

+ 将/for拷贝到/bar目录相当于一个MapReduce作业

## 3.9 Hadoop存档

### 3.9.1 使用Hadoop存档工具

+ 存档文件.har `hadoop archive -archiveName output.har -p /user/output /user `
+ 显示存档内容 `hadoop fs -ls har:///user/output.har `

# YARN

Apache YARN(Yet Another Resource Negotiator) 是Hadoop集群资源管理系统，是在Hadoop2引进来提高MapReduce实现，
同时也支持其他分布式计算平台

# Hadoop 的 I/O 操作

## 4.1 数据完整性

通过错误检测码 CRC-32 循环冗余校验，任何大小的数据输入都会计算得到一个32位的整数校验和

### 4.1.1 HDFS的数据完整性

1. 针对每个由io.bytes.per.checksum指定字节的数据计算校验和，默认512字节，CRC-32校验和是4字节，额外开销低于1%
2. datanode收到客户端发来的数据，会在管线的最后一个datanode进行数据校验，
如果有异常会抛出checksumException是IOException的子类，客户端会进行重试操作
3. 当从datanode读取数据时，数据会与存储在datanode中的校验和进行比较，每个datanode都会持久保存一个用于验证的校验和日志，
所以它知道每个数据块最后一个验证时间。每更新一个数据后，会告诉这个datanode更新日志。
每个datanode会后台运行一个DataBlockScanner定期进行数据验证。
4. 客户端读取数据块时，发现有数据错误，会向namenode报告已损坏的数据块并尝试读操作这个datanode，
并抛出checksumException。namenode会标记这个数据块复本，
之后会让这个数据块复本复制到另一个datanode，这样就是复本因子回归到期望值，之后便会删除已损坏数据块复本
5. 在open()方法调用前，FileSystem#setVerifyChecksum()设置false就可以禁用校验和验证

### 4.1.2 LocalFileSystem

执行客户端的校验和验证，使用RawLocalFileSystem在应用中实现全局校验和验证，
`fs.file.impl`属性设置为`org.apache.hadoop.fs.RawLocalFileSystem`进而实现对文件的URI重新映射

### 4.1.3 ChecksumFileSystem

1. LocalFileSystem通过ChecksumFileSystem来完成自己的任务对无校验和系统的加入
2. 通过ChecksumFileSystem#getRawFileSystem()获取底层raw文件系统
3. getChecksumFile()可以获取任意一个文件的校验和文件路径

```java
FileSystem rawFs = ...
FileSystem checksummedFs = new ChecksumFileSystem(rawFs);
```

## 4.2 压缩

1. 好处: 减少存储文件磁盘空间，并加速数据网络和磁盘传输速度
2. 需要权衡空间和时间
3. 所有压缩方式都有 -1～-9 的选项优化压缩～优化压缩空间
4. 压缩速率 `LZO, LZ4, Snappy > gzip > bzip2`
5. 压缩比 `bzip2 > gzip > LZO, LZ4, Snappy`
6. bizp2 可切分

### 4.2.1 codec

+ 每种压缩格式都 implements SplittableCompressionCodec extends CompressionCodec
  - LZO 需要下载, 格式为LzopCodec

+ CompressionCodec 对数据流进行压缩和解压缩

```java
/** Interface CompressionCodec# */
/** out the location for the final output stream */
CompressionOutputStream createOutputStream(OutputStream out) throws IOException;

/** in the stream to read compressed bytes from */
CompressionInputStream createInputStream(InputStream in) throws IOException;

/** 通过反射来获取指定压缩方式 */
String codecClassname = args[0];
Class<?> codecClass = Class.forName(codecClassname);
CompressionCodec codec = (CompressionCodec) ReflectionUtils.newInstance(codecClass, conf);
```
+ 通过对字符串Text进行压缩
`echo "Text" | hadoop StreamCompressor org.apache.hadoop.io.compress.GzipCodec | gunzip `

+ CompressionCodecFactory 来判断 CompressionCodec 
  - CompressionCodecFactory#getCodec 方法来返回对应的 CompressionCodec

+ 如果遇到大量压缩和解压操作可以使用CodecPool

```java
CompressionCodec codec = (CompressionCodec) ReflectionUtils.newInstance(codecClass, conf);
Compressor compressor = null;
compressor = CodecPool.getCompressor(codec);
CompressionOutpustream out = codec.createOutputStream(System.out, compressor);
CodecPool.returnCompressor(compressor)
```

### 4.2.2 压缩和切分

+ 如果默认为64MB数据块大小，1GB文件将会被切分为16个数据块。
如果使用不能从任意位置读取的压缩格式Gzip，将会导致有些从文件起始读取，有些从任意位置读取，数据一致性和同步的问题。
+ 在LZO下载工具包中带有索引工具可以支持MapReduce输入格式可有效实现文件切分的特点
+ bzip2也是唯一支持切分的格式，但是速度较慢

### 4.2.3 在MapReduce中使用压缩

+ 要想压缩MapReduce作业输出两种方法
  1. 对MapReduce输出压缩作业配置
    - `mapred.output.compress#false`
    - `mapred.output.compression.coded#org.apache.hadoop.io.compress.DefaultCodec`
  2. FileOutputFormat.setCompressOutput(job, true);
    - `FileOutputFormat.setOutputCompressorClass(job, GzipCodec.class);`

+ 如果输出为顺序文件 SequenceFile
  1. 设置mapred.output.compression.type属性
  2. 默认为 RECORD 针对每条记录进行压缩
  3. BLOCK 针对一组记录进行压缩
  4. 通过 SequenceFileOutputFormat#putCompressionType()
+ 对map任务输出压缩
  - `mapred.compress.map.output#false`
  - `mapred.map.output.compression.codec#org.apache.hadoop.io.compress.DefaultCodec`

## 4.3 序列化

1. 序列化是指将结构化对象转化为字节流以便在网络上传输或写到磁盘进行永久存储的过程
2. 进程间通信和永久存储
3. RPC序列化格式: 紧凑(进而高效使用存储空间)、快速(以读写数据的额外开销比较小)、可扩展(可以透明地读取老格式数据)、
支持互操作(可以使用不同语言读写永久数据)
4. Hadoop 使用自己的序列化格式 Writable 绝对紧凑、速度快、但是不容易被Java以外的语言扩展或使用，但是是核心，
所以有了Avro框架进行了弥补

### 4.3.1 Writable 接口

+ Interface Writable

```java
/** 接口定义的方法 */
void write(DataOutput out) throws IOException;
void readFields(DataInput in) throws IOException;
```
+ Interface `WritableComparable<T>`
  - Note that hashCode() is frequently used in Hadoop to partition keys. 
It's important that your implementation of hashCode() returns the same result across different instances of the JVM. 
Note also that the default hashCode() implementation in Object does not satisfy this property.

```java
/** Example */
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + counter;
    result = prime * result + (int) (timestamp ^ (timestamp &gt;&gt;&gt; 32));
    return result
  }
```

+ Comparator extends WritableComparator implements RawComparator, Configurable
  - 优化过的WritableComparator接口可以直接比较数据流中的记录，无需反序列化，避免不必要的开销

+ WritableComparator具有两个功能

+ 实现RawComparator#compare方法，可以实现在二进制中比较

```java
public int compare(byte[] b1, int s1, int l1, byte[] b2, int s2, int l2);
```

+ 通过WritableComparator#get方法可以作为RawComparator的实例工厂

```java
RawComparator<IntWritable> comparator = WritableComparator.get(IntWritable.class);
```

+ `IntWritable implements WritableComparable<IntWritable>` 是对 Java int 类型的封装

```java
/** Set the value of this IntWritable. */
public IntWritable(int value) { set(value); }
public void set(int value) { this.value = value; }
```

### 4.3.2 Writable 类

+ Java 基本类型 implements WritableComparable
  1. char可以存储在IntWritable中，封装中都会包含get()和set()方法
  2. IntWritable～4字节;VintWritable~1-5字节
  3. 变长格式如果编码数值很小就使用一个字节，否则就是第一个字节表示正负，后面接多少个字节
  4. 变长使用与数值分布不均匀的数值变量更节省空间，而且可以在VintWritable和VlongWritable转换，因为其编码是一致的，
所以选择变长之后，有增长空间，不必一开是就用8字节long表示

+ Text类型
  - 与String的区别
    1. Text是使用标准的 UTF-8 编码，使用整型变长编码方式最大值为2GB，字节数不能超过32767~~new byte[]
    2. String使用Unicode字符～～new char[]
    3. String.charAt(5) 返回 char
    4. Text.charAt(5) 返回 int Unicode编码位置
    5. Text.find("\uD801\uDC00") 返回字节偏移量
    6. Text#set方法使Text是可变的，String is immutable
  - UTF-8 Unicode Transformation Format 是针对Unicode的可变长度字符编码

Unicode      | 字节数
-------------|-------
0000-007F    | 1
0080-07FF    | 2
0800-FFFF    | 3
10000-1FFFFF | 4

Unicode  | U+0041  | U+00DF  | U+6771  | U+10400
---------|---------|---------|---------|-------------
Java     | \u0041  | \u00DF  | \u6771  | \uD801\uDC00
  
  - 迭代
    1. 通过ByteBuffer和Text#bytesToCodePoint来实现

```java
ByteBuffer buf = ByteBuffer.wrap(text.getBytes(), 0, text.getBytes().length);
while(buf.hasRemaining && (int cp = Text.bytesToCodePoint(buf) )!= -1){
    System.out.println(Integer.toHexString(cp));
}
```

+ BytesWritable
  - 格式为 长度+数字内容, 同样也是可变的通过#set

```java
BytesWritable writable = new BytesWritable(new byte[] {1, 3, 11}); // range -128~127
byte[] b = serialize(writable);
System.out.println(StringUtils.byteToHexString(b));

  public byte[] serialize(Writable writable) throw IOException {
    ByteArrayOutputStream bytes = new ByteArrayOutputStream();
    DataOutputStream out = new DataOutputStream(bytes);
    writable.write(out);
    out.close();
    return out.toByteArray();
  }
/** output: 0000000301030b */
```

+ NullWritable 
  - 不需要键值序列化地址可以用NullWritable，存储常量空值，可作为SequenceFile中的键，通过调用NullWritable#get获取实例

+ ObjectWritable & GenericWritable implements Writable
  - **ObjectWritable:** 是将以下Java类型进行序列化的封装类，
如果SequenceFile中的值包含多个类型就可以将值类型声明为ObjectWritable，并将每个类型封装在一个ObjectWritable中

```java
  private static final Map<String, Class<?>> PRIMITIVE_NAMES = new HashMap<String, Class<?>>();
  static {
    PRIMITIVE_NAMES.put("boolean", Boolean.TYPE);
    PRIMITIVE_NAMES.put("byte", Byte.TYPE);
    PRIMITIVE_NAMES.put("char", Character.TYPE);
    PRIMITIVE_NAMES.put("short", Short.TYPE);
    PRIMITIVE_NAMES.put("int", Integer.TYPE);
    PRIMITIVE_NAMES.put("long", Long.TYPE);
    PRIMITIVE_NAMES.put("float", Float.TYPE);
    PRIMITIVE_NAMES.put("double", Double.TYPE);
    PRIMITIVE_NAMES.put("void", Void.TYPE);
  }
```
  - **GenericWritable:** 如果封装类型数量较少，可以将已实现Writable的类定义以数组的形式定义在自己写的继承自
GenericWritable中，加入位置索引提高性能

```
/** 源码中的How to use */
how to use it:
1. Write your own class, such as GenericObject, which extends GenericWritable.
2. Implements the abstract method getTypes(), defines the classes which will be wrapped in 
GenericObject in application. Attention: this classes defined in getTypes() method, must implement
Writable interface.
```

```java
public class GenericObject extends GenericWritable {

   private static Class[] CLASSES = {
               ClassType1.class, 
               ClassType2.class,
               ClassType3.class,
               };

   protected Class[] getTypes() {
       return CLASSES;
   }
}
```

+ Writable 集合类 implements Writable
  - Array;ArrayPrimitive;TwoDArray;Map;SortedMap;EnumMapWritable
  - **ArrayWritable & TwoDArrayWritable:** 是对Writable数组和二维数组的封装类，通过构造方法是类型一定的，
同时拥有get(),set(),toArray()方法，toArray()可以新建数组但只是浅拷贝
  - **ArrayPrimitiveWritable:** 是对Java基本数组类型的封装，无需继承，通过set(Object object)来识别相应组件类型
  - **MapWritable & SortedMapWritable & EnumMapWritable:** 是继承自AbstractMapWritable，MapWritable#put
是调用AbstractMapWritable#`addToMap(Class<?> clazz, byte id)`将Writable.getClass()以byte id的方式存储在
ConcurrentHashMap classToIdMap & idToClassMap中并做检查是否已存在和超出存储容量范围，
同时存储在MapWritable#this.instance，MapWritable#write&readFields将id进行序列化存储可以根据id得到class类型，
MapWritable#`this.instance = new HashMap<Writable, Writable>();`是用来进行遍历索引的

```java
public class MapWritable extends AbstractMapWritable
  implements Map<Writable, Writable> {

  @Override
  public Writable put(Writable key, Writable value) {
    addToMap(key.getClass());
    addToMap(value.getClass());
    return instance.put(key, value);
  }

  @Override
  public void write(DataOutput out) throws IOException {
    super.write(out);
    
    // Write out the number of entries in the map
    
    out.writeInt(instance.size());

    // Then write out each key/value pair
    
    for (Map.Entry<Writable, Writable> e: instance.entrySet()) {
      out.writeByte(getId(e.getKey().getClass()));
      e.getKey().write(out);
      out.writeByte(getId(e.getValue().getClass()));
      e.getValue().write(out);
    }
  }
}
```

```java
  private synchronized void addToMap(Class<?> clazz, byte id) {
    if (classToIdMap.containsKey(clazz)) {
      byte b = classToIdMap.get(clazz);
      if (b != id) {
        throw new IllegalArgumentException ("Class " + clazz.getName() +
          " already registered but maps to " + b + " and not " + id);
      }
    }
    if (idToClassMap.containsKey(id)) {
      Class<?> c = idToClassMap.get(id);
      if (!c.equals(clazz)) {
        throw new IllegalArgumentException("Id " + id + " exists but maps to " +
            c.getName() + " and not " + clazz.getName());
      }
    }
    classToIdMap.put(clazz, id);
    idToClassMap.put(id, clazz);
  }
```

    - 单类型Writable使用ArrayWritable;不同Writable存储在单类表用GenericWrtiable，元素封装在ArrayWritable;
也可以用MapWritable写一个通用的ListWritable

### 4.3.3 实现定制的 Writable 集合

+ TextPair implements WritableComparable
  - [RawComparable](https://github.com/kunSong/Hadoop/blob/master/RawComparable.java)
    1. 所有Writable必须实现一个默认的构造方法以便MapReduce框架可以对它进行实例化
    2. Writable实例是可变的且可以重用，尽量避免在write()和readFields()中分配对象
    3. 需要重写hashCode(),equals(),toString()，会利用hashCode()来选择分区

  - 为速度实现一个RawComparator代码更新在TextPair中
    1. 原理: 当TextPair在MapReduce中作为键时，如果需要调用TextPair#compareTo()则需要反序列化为对象后进行比较并排序。
但是可以将TextPair还是以二进制表达的时候就进行比较，读取该对象起始长度，由此得知第一个Text对象字节表示长度，然后将长度
传递给Text对象，通过RawComparator，计算第一个字符串和第二个字符串恰当的偏移量来实现比较，Text对象的二进制表示是一个
长度可变的整数，包含字符串之UTF-8表示字节数和UTF-8字节本身
    2. Text对象有自己的Text.Comparator()，其他类似
    3. `WritableComparator.decodeVIntSize(byte value)`: Parse the first byte of a vint/vlong to 
determine the number of bytes
    4. `WritableComparator.readVInt(byte[] bytes, int start)`: Reads a zero-compressed encoded integer
from a byte array and returns it.
    5. `WritableComparator.defind(Class<?> class, Comparator comparator)`: 为实现WritableComparable的类
定义Comparator，注册这个比较器需要是要线程安全的　(Register an optimized comparator for a WritableComparable
implementation. Comparators registered with this method must be thread-safe.)

## 4.4 Avro

1. Avro是独立与编程语言之外的序列化系统，旨在解决Hadoop中Writable类型的不足，缺乏语言的可以移植性
2. Avro是用JSON写的，通常采用二进制，同时也支持Avro IDL实现
3. Avro有这丰富的模式解析能力(schema resolution)，支持模式演化，eg: 新字段加入记录，需要在老模式中声明，新读写新，
也可以读写旧，老会忽略新的字段按旧模式处理
4. Avro为对象指定了对象容器格式，Avro数据文件包含元数据项(模式数据存储在其中)可以自我声明，支持压缩，切分和RPC

### 4.4.1 Avro 数据类型和模式

+ Avro 基本类型

```
null "null"
boolean "boolean"
int "int"
/** 使用type属性指定 */
{ "type": "null" }
```

+ Avro 复杂类型

```json
/** record 一个任意类型的命名字段集合　*/
{
  "type": "record",
  "name": "WeatherRecord",
  "doc": "A weather reading.",
  "fields": [
    { "name": "year", "type": "int"},
    { "name": "temperature", "type": "int"},
    { "name": "stationId", "type": "string"}
  ]
}
```

+ Avro Java 类型映射
  - **Generic 通用映射:** 即使运行前并不知道具体模式，也可以使用动态映射 
  - **Java 特殊映射:** 自动生成代码来表示符合某种Avro模式的数据
  - **Java 自反映射:** 将Avro类型映射到已有的Java类型，速度慢不推荐
  - 基本上都是相同的，通用映射和特殊映射仅在record，enum和fixed有区别，其他均为自动生成，由name属性
和可选的namespace属性决定

### 4.4.2 内存中的序列化和反序列化

```json
{
  "type": "record",
  "name": "StringPair",
  "doc": "A pair of strings.",
  "fields": [
    { "name": "left", "type": "string" },
    { "name": "right", "type": "string" },
  ]
}
```

+ [AvroDataMemorySerialize](https://github.com/kunSong/Hadoop/blob/master/AvroDataMemorySerialize.java)

### 4.4.3 Avro 数据文件

+ 数据文件的头部分包含元数据，包含一个Avro模式和一个sync marker同步标识，接着是包含序列化Avro对象数据块。数据块由
sync marker分隔，是唯一，并切允许在文件中搜索到任意位置之后通过块边界快速地重新进行同步。因此Avro数据文件是可切分的，
适合MapReduce快速处理

+ [AvroDataFile](https://github.com/kunSong/Hadoop/blob/master/AvroDataFile.java)

```json
{
  "type": "record",
  "name": "StringPair",
  "doc": "A pair of strings.",
  "fields": [
    { "name": "left", "type": "string" },
    { "name": "right", "type": "string" },
    { "name": "count", "type": "int" },
    { "name": "really", "type": "boolean" }
  ]
}
```

### 4.4.5 模式的解析

+ 读和加时候的数据模式可以不同于写入时候的数据模式

+ 当写入时的数据模式为#4.4.2#Schema，而读取数据是使用如下Schema，这里指定了description默认值为空字符串，供Avro在
读取没有定义字段的记录时使用。如果没有default属性，在读取旧数据时会报错。如果要是用null，需要并集定义
`{ "name": "description", "type": ["null", "string"], "default": "null" }` 

```json
{
  "type": "record",
  "name": "StringPair",
  "doc": "A pair of strings.",
  "fields": [
    { "name": "left", "type": "string" },
    { "name": "right", "type": "string" },
    { "name": "description", "type": "string", "default": "" }
  ]
}
```

```java
/** 可以通过构造方法 */
DatumReader<GenericRecord> reader = new GenericDatumReader<GenericRecord>(writerSchema, readerSchema);

/** 如果元数据中有写入模式的数据文件，可以将其置null */
DatumReader<GenericRecord> reader = new GenericDatumReader<GenericRecord>(null, newSchema);
```


+ 如果要去掉一些记录中的字段，叫投影 projection

```json
{
  "type": "record",
  "name": "StringPair",
  "doc": "A pair of strings.",
  "fields": [
    { "name": "left", "type": "string" }
  ]
}
```

+ 记录的模式演化`表4-12`

+ 使用别名

```json
{
  "type": "record",
  "name": "StringPair",
  "doc": "A pair of strings.",
  "fields": [
    { "name": "first", "type": "string", "aliases": ["left"] },
    { "name": "second", "type": "string" "aliases": ["right"] }
  ]
}
```

### 4.4.6 排列顺序

+ 通过指定order进行排序，ignore可以忽视不进行字段比较，avro实现了高效的二进制比较，不写order也会比较，不需要将
二进制对象反序列化成对象就可以实现比较，直接对字节流进行操作，与4.3.3节描述RawCompartor类似，先比较第一个UTF-8编码
字段，如果顺序不清楚则停止，如果清楚就按字母表进行排序，如果相同继续比较第二个UTF-8编码的字符串。

```json
{
  "type": "record",
  "name": "StringPair",
  "doc": "A pair of strings, sorted by right field descending",
  "fields": [
    { "name": "left", "type": "string", "order": "ignore" },
    { "name": "right", "type": "string" "order": "descending" }
  ]
}
```

### 4.4.7 关于 Avro MapReduce

+ 使用org.apache.avro.mapred.Pair来包裹map输出的键和值，因为Map后会混洗输出，在Reduce之前需要对Pair解包，对每个
键年份都可以执行迭代运算

+ [AvroMapReduce](https://github.com/kunSong/Hadoop/blob/master/AvroMapReduce.java)

### 4.4.8 使用 Avro MapReduce 排序

+ 与4.4.7类似，利用泛型类型参数K表示的任何Java类型的Avro记录进行排序

```java
static class SorReducer<K> extends AvroReducer<K, K, K> {
  public void reduce(K key, Iterable<K> values,
      AvroCollector<K> collector,
      Reporter reporter) throws IOException {
    for(K value : values) {
      collector.collect(value);
    }
  }
}
```

## 4.5 基于文件的数据结构 

## 4.5.1 关于SequenceFile

+ SequenceFile是对二进制文件类型数据，二进制键和值的持久化数据结构，同时HDFS是对大文件的优化，若干个小文件可以被包装
成SequenceFile，有效提高效率

+ **SequenceFile读写文件:**
[SequenceFileDemo](https://github.com/kunSong/Hadoop/blob/master/SequenceFileDemo.java)
 
+ 同步点
  1. Writer会在特定的位置的记录上加上一个同步点
  2. `[1976]～[2021]` 为那条记录的边界，如果在`[1976]`处查询会得到那条记录结果，如果在这个中间去获取记录会报错
  3. 使用`sync()`边界中的值，会同步到对应下一个同步点位置，如果后面没有同步点，则会同步到文件末尾
  4. 与`Syncable()`接口中的`sync()`方法不同，前者为在流中插入同步点，后者为底层设备缓存区的同步

```
[1976]  60  One, two, buckle my shoe
[2021*] 59  Three, four, shut the door
[2088]  58  Five, six, pick up sticks
```

```java
/** I */
reader.seek(1976);
assertThat(reader.next(key, value), is(true));
assertThat(((IntWirtable) key).get(), is(60));

reader.seek(2000);
assertThat(reader.next(key, value), is(true)); //fail with IOException

/** II */
reader.sync(2000);
assertThat(reader.getPosition(), is(2021L));
assertThat(reader.next(key, value), is(true));
assertThat(((IntWirtable) key).get(), is(59));
```

+ **查看SequenceFile命令行:** `hadoop fs -text SequenceFile.seq | head`

+ 除了通过MapReduce来排序，SequenceFile本身也可以实现排序和合并，通过`Sorter#sort()&merge()`

```java
SequenceFile.Sorter sort = new SequenceFile.Sorter
    (FileSystem fs, Class<? extends WritableComparable> keyClass, Class valClass, Configuration conf)
```

+ SequenceFile 文件格式
  1. 顺序文件
    - 头文件和随后的一条或多条记录组成，中间穿插同步点
  2. 压缩格式
    - 块压缩一次性压缩多条记录(Number of records, Compressed key lengths, Compressed keys, Compressed 
value lengths, Compressed values)

### 4.5.2 关于MapFile

+ MapFile是已经排序过的SequenceFile，有索引可以按键查找，可视为java.util.Map的持久化形式

+ 读写操作类似与SequenceFile
  1. 必须顺序写入否则会抛出IOException
  2. MapFile包含两个文件夹 data和index， 命令行 `hadoop fs -text number.map/data(index) | head`
  3. 先用二分查找寻找内存中的索引，然后找到对应的data偏移量顺序读data中的键直到找到值，默认只有每隔128个键才有一个
包含在index文件中，通过`setIndexInterval()`设置，io.mao.index.skip属性可以设置跳过数量，
`2`相当于只读索引三分之一的键，设置越大可降低内存，但是会降低寻找效率
  4. getClosest()找到最接近的值而不是返回null

+ MapFile变种
  - **SetFile:** Writable键，必须按拍好顺序添加
  - **ArrayFile:** key is int as index, value is writable
  - **BloomMapFile:** 对稀疏文件有用，通过内存中的booleam过滤器来判断是否存在，存在则调用get()，假阳性概率0.5% 

+ SequenceFile 转换为 MapFile
  - fix()重建索引

```java
Configuration conf = new Configuration();

FileSystem fs = FileSystem.get(URI.create(mapUri), conf);
Path map = new Path(mapUri);
Path mapData = new Path(map, MapFile.DATA_FILE_NAME);

// Get key and value types from data sequence file
SequenceFile.Reader reader = new SequenceFile.Reader(fs, mapData, conf);
Class keyClass = reader.getKeyClass();
Class valueClass = reader.getValueClass();
reader.close();
// Create the map file index file
long entries = MapFile.fix(fs, map, keyClass, valueClass, false, conf);
```

# MapReduce 应用开发

## 5.1 用于配置的API

+ 从资源中读取xml配置文件

```java
Configuration conf = new Configuration();
conf.addResourece("configuration-1.xml");

/** 可以添加第二个conf文件对前者如果内容相同可以覆盖，但是如果定义为final属性是不能被覆盖的*/
conf.addResourece("configuration-2.xml");
```

```
/** 可以定义扩展 */
<property>
  <name>size-weight</name>
  <value>${size},${weight}</value>
  <description>Size and weight</description>
</property>
```

### 5.2.1 管理配置

+ 可以将 ssh localhost 不需要密码

```
/* on Web */
ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
export HADOOP\_PREFIX=/usr/local/hadoop

/* on Guide */
ssh-keygen -t rsa -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

```
/etc/hadoop/core-site.xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
/etc/hadoop/hdfs-site.xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value> //仅有一个备份
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:/opt/hadoop/hdfs/name</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:/opt/hadoop/hdfs/data</value>
    </property>
</configuration>
```
1. 在 core-site.xml 中定义hdfs
2. 将hadoop-eclipse-plugin-2.7.2.jar拷贝到eclipse/plugins下
3. 右上角增加Map/Reduce
4. 增加Hadoop Location
5. Map/Reduce(V2) Master Host:localhost Port:50070
6. DFS Master Host:localhost Port:9000 并勾选
7. 修改hadoop.tmp.dir
8. hdfs namenode -format
9. start-dfs.sh

+ 至此就可以在eclipse中看到DFS location，同时也可以通过...进行不同配置的切换
`hadoop -config conf/hadoop-localhost.xml -ls  `

### 5.2.2 GenericOptionsParser, Tool and ToolRunner

1. 实现Tool#run()，通过继承自 Configured#getConf() 得到定义在xml中的confgiuration
2. Configuration 继承自 Iterable 和 writable，可以通过 Entry`<String, String>`来获取键值
3. 在main方法中会用ToolRunner调用静态方法run()，从Tool对象获取configuration，使用GenericOptionsParser
对conf进行解析，调用现子在实现Tool接口后的类的run()方法

```java
public class ConfigurationPrinter extends Configured implements Tool{
  static {
    Configuration.addDefaultResource("core-site.xml");;
  }

  @Override
  public int run(String[] args) throws Exception {
    Configuration conf = getConf();
    for(Entry<String, String> entry : conf){
      System.out.printf("%s=%s\n", entry.getKey(), entry.getValue());
    }
    return 0;
  }

  public static void main(String[] args) throws Exception {
    int exitCode = ToolRunner.run(new ConfigurationPrinter(), args);
    System.exit(exitCode);
  }
}
```

+ 当在加载完配置文件后可以，可以通过 GenericOptionsParser 设置个别属性，通过-D来覆盖原来的配置。
`hadoop ConfigurationPrinter -D color=yellow | grep color ` 其他属性参见`表5-1`

## 5.3 用 MRUnit 来写单元测试

### 5.3.1 关于Mapper

+ 利用MRUnit中MapDriver进行输入输出值的测试，如果没有我们期望的值则测试失败，此处mapper忽视输入key

```java
new MapDriver<LongWritable, Text, Text, IntWritable>()
        .withMapper(new MaxTemperautreMapper())
        .withInputValue(value)
        .withOutput(new Text("1950"), new IntWritable(-11))
        .runTest()
```

### 5.3.2 关于Reducer

+ 利用MRUnit中ReduceDriver进行输入输出值的测试

```java
new ReduceDriver<Text, IntWritable, Text, IntWritable>()
        .withReducer(new MaxTemperautreReducer())
        .withInputkey(new Text("1950"))
        .withInputValues(Arrays.asList(new IntWritable(10), new IntWritable(5)))
        .withOutput(new Text("1950"), new IntWritable(10))
        .runTest()
```

## 5.4 本地运行测试数据

### 5.4.1 在本地作业运行器上运行作业
### 5.4.2 测试驱动程序

1. 和第二章中Demo差不多
2. `mapred.job.tracker` 是一个主机，用来设置jobtrakcer地址，此处为local值
3. 通过GenericOptionsParser提供 -fs和-jt来设值
`% hadoop v2.MaxTemperatureDriver -fs file:/// -jt local input/ncdc/micro`
4. 利用封装的Parser来判断输入是否合法并且可以重用
5. 通过 `conf.set("mapred.job.tracker", "local");` 同样可以设置configuration值

## 5.5 在集群上运行

### 5.5.1 打包作业

1. 客户端的类路径
2. 任务的类路径
3. 打包依赖
4. 任务类路径的优先权

### 5.5.2 启动作业

+ hadoop job 命令查询某个作业，必须要有ID信息

### 5.5.3 MapReduce 的 Web 界面

+ jobtracker 页面
  1. `http://jobtracker-host:50030/`
  2. 集群负载情况和使用情况 

+ 作业页面

### 5.5.4 获取结果

`hadoop fs -cat max_temp/*`

### 5.5.5 作业调试

1. 任务页面
2. 任务详细信息页面
3. 处理不合理的数据

### 5.5.6 Hadoop 日志

```java
private static final Log LOG = LogFactory.getLog(LoggingIdentifyMapper.class);
LOG.info("Map key: " + key);
LOG.debug("Map value:" + value);
```

+ `表5-2`

### 5.5.7 远程调试

## 5.6 作业调优

+ 作业调优检查`表5-3`

### 5.6.1 分析任务

+ **HPROF 分析工具:** 是JDK自带的分析工具
+ **Distributed Cache 分布式缓存:** @8.4.2

## 5.7 MapReduce 的工作流

### 5.7.1 将问题分解成 MapReduce 作业

### 5.7.2 关于 JobControl

+ JobControl 实例表示一个作业运行图，在一个线程中运行JobControl时，它将按照依赖顺序来执行这些作业，也可以查看进程，
在作业结束后，可以查询作业的所有状态和每个失败相关的错误信息。如果一个作业失败，JobControl将不执行与之有依赖关系的后
续作业

### 5.7.3 光于 Apache Oozie

+ Ooize 作为服务器运行，客户端会提交一个立即或稍后执行的工作流到服务器，在Oozie中，工作流是一个有动作节点和控制流节点
组成的 DAG 有向无环图

+ 定义 Oozie 工作流
  1. 以xml形式书写 workflow.xml
  2. 大多为 MapReduce 作业 Configuration 元素中设定的值类似
  3. 每个工作流需要一个start和end节点
  4. 打包Oozie工作流应用需要一个workflow.xml和MapReduce应用
  5. 运行Oozie工作流 `oozie job -config ...`

### 备注

1. 缺少第四版YARN内容
2. 5.4之后内容需要与实战联系

