# iOS -Engineering
关于架构的总结

1. 子工程化 frameWork-- > Static || Dynamic
1.1 新增关于category中关联属性的使用

2. 本地pod管理

3. Objection - 组件化

4. JLRoute - 路由(JLRoute并不是较好方案)

   

## PT && PX
1. 1pt其实是包含了很多px的  像素越多越清晰 包含的信息越多 是很多px表示1pt

2. 所以同样的10px 在越高的分辨率上 物理长度越短

3. 所以才有Retina屏的说法 （1pt 包含2px 包含3px）

4. 适配就是等比转换pt 像素其实是发生变化的 只有比例保持不变

5. 些字体等比缩小太小了看不见 所以直接使用pt

   

## 动态库和静态库在包大小上的区别
1. 对于装在用户手机上的大小没有区别

2. 动态库减小的大小其实是在打包完了的文件中的主二进制文件

3. 在包含主二进制文件的文件目录（这个文件目录就是打完包后的.app 显示包内容的文件）下有单独的Frameworks文件夹， 动态库放在了文件夹里 静态库直接打在了主二进制文件里

4. 缩减的这部分大小啥时候有用呢 就是在上传的时候 苹果对主二进制文件有大小要求 但是针对独立的架构下的（arm7 arm64）分别计算出的大小 是整体的大小

   

## APPStore 描述和新功能的位置
1. 新功能在预览的上面 描述在预览的下面

   

## 添加动态库为子工程
1.     手动添加（没啥用）首先 建好主工程和子工程 主工程 pod init->pod install 创建出worksapce 然后打开worksapce->manage Schemes 将对应的Container由project修改为worksapce 然后回目录addfileto就完成了。 这边主要注意 project修改为 worksapce就行了 为啥说没啥用呢 面pod的部分。

2.     通过pod添加 
```ruby
workspace 'MainProject.xcworkspace'
target 'MainProject' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!
  # Pods for MainProject
	pod 'AFNetworking', :path => '~/.cocoapods/repos/SNEBuy_repos/AFNetworking/2.5.5'
	pod 'TT', :path => '../LocalPod/TT'
 	pod 'SNObjection',:path => '~/.cocoapods/repos/SNEBuy_repos/SNObjection/1.0.1'
		target 'TTF' do
			project '../TTF/TTF.xcodeproj'
		end
end

```
> 对上面解释一下 首先 指定一个xcworkspace 然后将需要添加动态库写进去（target TTF ） target的名字为xcodeproj的文件名 使用project指令自动生成子工程 ；
这样写的话 pod的库子工程和主工程都能用 。
一般独立的业务动态库都会使用类似afn等工具所以 通过pod添加能自动添加对应的依赖。


3. 动态库懒加载</br>
   3.1去除主工程对需要懒加载库的依赖 TARGETS --> General --> Frameworks,Libraries,andEmbedded Content --> 删除对应的依赖</br>
   3.2在需要使用的地方调用dlopen 打开指定的动态库（需要#import <dlfcn.h>）
   </br>
   3.3以这个TTF为例：

   ```objective-c
   NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
   NSString *libPath = [bundlePath stringByAppendingPathComponent:@"Frameworks/TTF.framework/TTF"];
   //这里的path 通过xcarchive可以发现mainBundle下面固定有一个文件夹叫Frameworks 所有的动态库就放在其中
   void *lib = dlopen([libPath UTF8String], RTLD_LAZY);
   if (lib) {
      // 相关业务代码
   }
   
   ```
> 注意：主工程去除了对动态库的依赖后 编译时不会带着动态库一起编译，即framework为上一次编译的结果 在子工程中修改了文件后需要重新 build一下。 建议开发时不要删除依赖 在打包时再删除。
   
>如果本地pod中使用的category，需要使用 在podspec文件中添加 spec.xcconfig = { 'OTHER_LDFLAGS' => '-ObjC -all_load -force_load' }

## 解耦
1.     解耦的本质是在不引用某个类的情况下试用这个类 
2.     目前常用的办法是三种 ##URL Router ##Target-Action ##Protocol - Class
2.2    URL Router
       类在load方法时注册好block
        利用UIApplication的方法 openUrl 来使用block
        (通过URL绑定和Class的关系)

2.3    Target-Action
        利用runtime 通过字符串找出 class 和对应的method   
        
2.4   Protocol - Class
    (通过)Protocal绑定class
​    找出类 还是runtime的方法 不过对应的method 使用协议来实现不通过runtime去找方法。



## 启动图不更新
1.      启动图不更新是因为在app本地会根据当前版本的launchscreen展示出的内容生成一张启动图的图片缓存在Documents/Library/SplashBoard，系统也会给这个图片缓存做一个相应的内存缓存。双缓存机制，图片缓存在storyboard里的图片名称都变化时会重新生成，内存缓存在被清除内存时会被清除（如重启），如果图片缓存为空，系统会生成图片缓存并且生成相应的内存缓存。
2.      在每次app启动完成后，要把本地的图片缓存删掉，并且app的新版本要把storyboard里边的图片名称都换掉。


## 电量测试

较准确的做法是导出手机的分析文件（和崩溃日志的在一个地方）
文件名为  Sysdiagnose 不用安装证书了 需要同时按住音量加减和开机键


1. select id from PLAccountingOperator_EventNone_Nodes where name='BundleID'
2. select id,timestamp,timeInterval,BundleID,ScreenOnTime from PLAppTimeService_Aggregate_AppRunTime where BundleID=''
3. select sum(Energy)/1000.000 from PLAccountingOperator_Aggregate_RootNodeEnergy where NodeId='' and timestap=
计量单位为 mWh （毫瓦时）

## pod的project中为什么有的是圈 有的是文件夹的target？
pod会判断podspec中的文件配置 如果没有.m 则认为不需要编译 当成resource资源直接链接
source_files 中增加了.m 他就变成了正常的target