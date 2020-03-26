# iOS -Engineering
关于架构的总结

1. 子工程化 frameWork-- > Static || Dynamic
1.1 新增关于category中关联属性的使用

2. 本地pod管理
3. Objection - 组件化
4. JLRoute - 路由

## PT && PX
1.     1pt其实是包含了很多px的  像素越多越清晰 包含的信息越多 是很多pt表示1px
2.     所以同样的10px 在越高的分辨率上 物理长度越短
3.     所以才有Retina屏的说法 （1pt 包含2px 包含3px）
4.     适配就是等比转换pt 像素其实是发生变化的 只有比例保持不变
5.      些字体等比缩小太小了看不见 所以直接使用pt

## 动态库和静态库在包大小上的区别
1.     对于装在用户手机上的大小没有区别
2.     动态库减小的大小其实是在打包完了的文件中的主二进制文件
3.     在包含主二进制文件的文件目录（这个文件目录就是打完包后的.app 显示包内容的文件）下有单独的Frameworks文件夹， 动态库放在了文件夹里 静态库直接打在了主二进制文件里
4.     缩减的这部分大小啥时候有用呢 就是在上传的时候 苹果对主二进制文件有大小要求 但是针对独立的架构下的（arm7 arm64）分别计算出的大小 是整体的大小

## APPStore 描述和新功能的位置
1.     新功能在预览的上面 描述在预览的下面

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
> 对上面解释一下 首先 指定一个xcworkspace 然后将需要添加动态库写进去（target TTF ） 使用project指令自动生成子工程 
这样写的话 pod的库子工程和主工程都能用 
一般独立的业务动态库都会使用类似afn等工具所以 通过pod添加能自动添加对应的依赖
