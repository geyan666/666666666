---
layout: post
title: "微信小程序：出发吧一起"
date: 2017-12-04 13:45
comments: true
categories: [微信小程序]
tags: [JS,微信小程序]
copyright: true
---
<center>
<img src="http://ovasw3yf9.bkt.clouddn.com/blog/171203/mjIhk6LFBE.png?imageslim" width="250px" />
</center>

## 前言

经过将近一个多月的开发,我们团队开发的微信小程序 "出发吧一起" 终于开发完成,现在的线上版本为 2.2.4-beta 版

本文档主要介绍该小程序在开发中所用到的技术,已经在开发中遇到问题的采取的解决方法

## 小程序简介

“让兴趣不再孤单，让爱好不再流浪” 是微信小程序《出发吧一起》的主题，这款小程序旨在解决当代大学生在校园生活中的孤独感，让大家找到志同道合的朋友，在跑步、健身、竞赛等活动中找到伙伴。利用小程序即开即用，用完就走的特点与交友相结合，它将会是一款高效快捷、无负担的线下交友利器

本小程序由 [bmob](https://www.bmob.cn/) 后端云提供数据处理与存储支持

## 小程序码

<center>
欢迎扫描体验
<center>
</center>
<img src="http://ovasw3yf9.bkt.clouddn.com/blog/171203/1fIA6jdFla.jpg?imageslim" width="250px" />

</center>

## 开发中技术问题汇总

### 1.使用e.target.dataset的出现问题

在小程序开发过程中,我们经常会用到标签中属性的属性值,我们通常会在 `<view>` 中 设置 `data-*="{{XXX}}"` 然后在 `JS` 里通过 `e.target.dateset.*` 来获取`XXX`值,但是我经常遇到获取的是`undefined`,使用 `console.log(e)` 查看输出信息会发现,在 `e`对象中包含两个对象分别是`currentTarget`和`target`,而往往有些时候数据在`currentTarget`中,

此时可以将代码替换成这样来获取值

- WXML

```html
<view bindtap="bintap" data-id="1"></view>
```

- JS

```javaScript
bintap:function(e){
    var id = e.currentTarget.dataset.id;
}
```
网上还有一直说法是 `data-*` 里 `*` 命名的问题,去掉驼峰式命名,纯小写也能解决

### 2.小程序 textarea 文本框如何显示实时字数

- WXML

```html
<view>
    <view>
        <textarea name="content" bindinput="bindTextAreaChange" maxlength="{{noteMaxLen}}" />
        <view class="chnumber">{{noteNowLen}}/{{noteMaxLen}}</view>
    </view>
</view>
```

- JS

```javaScript
data:{
    noteMaxLen: 200,//备注最多字数
    noteNowLen: 0,//备注当前字数
}

  //字数改变触发事件
  bindTextAreaChange: function (e) {
    var that = this
    var value = e.detail.value,
      len = parseInt(value.length);
    if (len > that.data.noteMaxLen)
      return;
    that.setData({
      content: value, noteNowLen: len
    })
  },
```

### 3.利用 JS 实现模糊查询

由于我们使用的是 [Bmob](https://www.bmob.cn/) 后端云提供的数据处理与存储支持，根据 Bmob 提供的开发文档，免费版的应用无法进行模糊查询，看到这里，再看看已经快完工的活动检索界面，感受无法言说。正当准备放弃的时候，突然想到一个方法，那就是先把所有的后台所有数据都存到集合里，然后根据输入的检索值一个个匹配，想到之后马上就开始着手干了，先查了一下`javaScript` 文档,`String` 对象有一个方法是 `indexOf()` ,可返回某个指定的字符串值在字符串中首次出现的位置,这样就成了,遍历 所以数据,检索每一条数据的每个字符,如果出现了则将它加入到检索结果的集合中.

- JS

```javaScript
//js 实现模糊匹配查询
  findEach: function (e) {
    var that = this
    var strFind = that.data.wxSearchData.value; //这里使用的 wxSearch 搜索UI插件,
    if (strFind == null || strFind == "") {
      wx.showToast({
        title: '输入为空',
        icon: 'loading',
      })
    }
    if (strFind != "") {
      var nPos;
      var resultPost = [];
      for (var i in smoodList) {
        var sTxt = smoodList[i].title || ''; //活动的标题
        nPos = sTxt.indexOf(strFind); 
        if (nPos >= 0) {//如果输入的关键字在该活动标题中出现过,则匹配该活动
          resultPost.push(smoodList[i]); //将该活动加入到搜索到的活动列表中
        }
      }
      that.setData({
        moodList: resultPost
      })
    }
  },

```
更加详细的代码请前往[Github](https://github.com/dmego/together)查看

### 4.使用 JS 将字符串格式的时间转换成几秒前,几分钟前...

由于小程序中涉及评论,加入活动,收藏等一系列包括事件时间的功能,而数据库中存的时间格式为 `2017-11-30 23:36:10` 现在想要在界面上不显示具体时间,而是显示与当前时间的差,即几秒前,几分钟前等等

实现起来并不复杂,主要思路是先把字符串的时间转换成时间戳,然后与当前的时间戳进行比较,这样就能转换成几秒前、几分钟前、几小时前、几天前等形式了

- JS

```javaScript
//字符串转换为时间戳
function getDateTimeStamp(dateStr) {
  return Date.parse(dateStr.replace(/-/gi, "/"));
}
//格式化时间
function getDateDiff(dateStr) {
  var publishTime = getDateTimeStamp(dateStr) / 1000,
    d_seconds,
    d_minutes,
    d_hours,
    d_days,
    timeNow = parseInt(new Date().getTime() / 1000),
    d,

    date = new Date(publishTime * 1000),
    Y = date.getFullYear(),
    M = date.getMonth() + 1,
    D = date.getDate(),
    H = date.getHours(),
    m = date.getMinutes(),
    s = date.getSeconds();
  //小于10的在前面补0
  if (M < 10) {
    M = '0' + M;
  }
  if (D < 10) {
    D = '0' + D;
  }
  if (H < 10) {
    H = '0' + H;
  }
  if (m < 10) {
    m = '0' + m;
  }
  if (s < 10) {
    s = '0' + s;
  }

  d = timeNow - publishTime;
  d_days = parseInt(d / 86400);
  d_hours = parseInt(d / 3600);
  d_minutes = parseInt(d / 60);
  d_seconds = parseInt(d);

  if (d_days > 0 && d_days < 3) {
    return d_days + '天前';
  } else if (d_days <= 0 && d_hours > 0) {
    return d_hours + '小时前';
  } else if (d_hours <= 0 && d_minutes > 0) {
    return d_minutes + '分钟前';
  } else if (d_seconds < 60) {
    if (d_seconds <= 0) {
      return '刚刚';
    } else {
      return d_seconds + '秒前';
    }
  } else if (d_days >= 3 && d_days < 30) {
    return M + '-' + D + ' ' + H + ':' + m;
  } else if (d_days >= 30) {
    return Y + '-' + M + '-' + D + ' ' + H + ':' + m;
  }
}
```

### 5.微信小程序提交表单清空表单数据

在发布活动之后,由于表单中的数据没有清空,给用户的体验必定不好,然而小程序的数据交互并不像`html + jS` 那样,使用 `dataSet({})` 来给赋值,视图层就能通过异步的方式活动到值,于是想到,在提交表单后,给这些`input`都赋值为空,那样就实现了清空表单的效果,当然,表单中并不只包含`input`,但是都可以通过这种方式实现清空效果

- WXML

```html
<form bindsubmit="submitForm">
    <text class="key">活动名称</text>
    <input name="title"  maxlength="100" value="{{title}}" />
    <button  formType="submit">确定</button>
</form>
```

- JS

```javaScript
submitForm:function(e){
     var title = e.detail.value.title;
     ......
     success: function (res) {
         //将title值设置空
        that.setData({
            title: ''
         }
     }
}
```

### 6.微信号,QQ号,手机号 正则校验

由于申请加入活动需要填写真实姓名,联系方式等信息,为了防止用户随意填写信息,必须要对这些信息进行校验

- JS

```javaScript
    var wxReg = new RegExp("^[a-zA-Z]([-_a-zA-Z0-9]{5,19})+$"); //微信号正则校验
    var qqReg = new RegExp("[1-9][0-9]{4,}"); //QQ号正则校验
    var phReg = /^1[34578]\d{9}$/; //手机号正则校验
    var nameReg = new RegExp("^[\u4e00-\u9fa5]{2,4}$"); //2-4位中文姓名正则校验
```

### 7.使用 Bmob SDK 实现报名成功发送模板消息,生成小程序二维码等

在开发过程中,由于想要实现,当用户报名成功后如何通知用户,查阅了小程序的开发文档发现有一个发送模板消息的API,再查询 Bmob 的开发文档,发现实现了这个功能,这个真的太有用了.模板消息只能再真机上才能发送成功,经过配置,重要成功,但是有在使用中出现一个问题
,就是在小程序发布后 模板消息中如果带有  `page` 参数将不会发送,但是在开发版中能发送成功, 这个问题已经反馈了,估计等Bmob小程序`SDK`更新后会解决这个问题.

具体代码我就不写了,bmob开发文档直达
- [发送模板消息](https://docs.bmob.cn/data/wechatApp/b_developdoc/doc/index.html#小程序模板消息)
- [生成小程序二维码](https://docs.bmob.cn/data/wechatApp/b_developdoc/doc/index.html#生成小程序二维码)

## 感谢以下开源项目、网站社区
- [Bmob后端云](https://docs.bmob.cn/)
- [微信小程序联盟](http://www.wxapp-union.com/)
- [WeUI for 小程序](https://github.com/Tencent/weui-wxss)
- [有赞小程序 UI 库](https://github.com/youzan/zanui-weapp)
- [微信小程序自定义组件（对话框、指示器、五星评分...）](https://github.com/skyvow/wux)
- [微信小程序优雅的搜索框](https://github.com/icindy/wxSearch)
- [We重邮](https://github.com/mcc108/wecqupt)
- [QQ 向左滑动删除操作](https://github.com/songzeng2016/wechat-app-LeftSlide)
- [模仿QQ6.0侧滑菜单](https://github.com/zhongjie-chen/wx-drawer)
- [守望轩](https://www.watch-life.net/)

.....