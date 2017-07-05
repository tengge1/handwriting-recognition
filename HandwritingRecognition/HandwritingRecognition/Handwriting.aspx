<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Handwriting.aspx.cs" Inherits="HandwritingRecognition.Handwriting" %>

<!DOCTYPE html>

<html lang="zh-cn">
<head runat="server">
    <meta charset="utf-8" />
    <title>手写识别</title>
    <style>
        body {
            margin: 0;
            padding: 0;
        }

        .box {
            width: 303px;
            height: 238px;
            position: relative;
            background: url(resource/images/write_bg.png) no-repeat #fff;
        }

        .book {
            position: absolute;
            left: 0px;
            top: 28px;
        }

        .close {
            position: absolute;
            left: 280px;
            top: 5px;
            width: 20px;
            height: 20px;
            cursor: pointer;
        }

        .tbl {
            position: absolute;
            left: 216px;
            top: 28px;
            width: 88px;
            table-layout: fixed;
        }

            .tbl td {
                height: 36px;
                text-align: center;
                vertical-align: middle;
                cursor: pointer;
            }

        .rewrite {
            position: absolute;
            left: 216px;
            top: 208px;
            width: 85px;
            height: 28px;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <div class="box">
        <canvas id="canvas1" class="book" width="216" height="208"></canvas>
        <div id="close" class="close"></div>
        <table id="choose" class="tbl" cellspacing="0" cellpadding="0">
            <tr>
                <td></td>
                <td></td>
            </tr>
            <tr>
                <td></td>
                <td></td>
            </tr>
            <tr>
                <td></td>
                <td></td>
            </tr>
            <tr>
                <td></td>
                <td></td>
            </tr>
            <tr>
                <td></td>
                <td></td>
            </tr>
        </table>
        <div id="rewrite" class="rewrite"></div>
    </div>
    <div id="result"></div>
    <script src="resource/js/jquery.js"></script>
    <script>
        // 手写板初始化
        var isMouseDown = false;
        var data = "";
        var old_x = 0;
        var old_y = 0;
        $(function () {

            // 鼠标按下
            $("#canvas1").mousedown(function (e) {
                isMouseDown = true;
            });

            // 鼠标弹起
            $("#canvas1").mouseup(function (e) {
                isMouseDown = false;

                // 更新候选字
                var obj = {
                    uid: "222.134.87.102",
                    type: "1",
                    data: data + ",-1,0"
                };
                $.post("api/HWSingleWriting.ashx", {
                    data: JSON.stringify(obj)
                }, function (data) {
                    var obj = JSON.parse(data);
                    var words = obj.result.split(',');
                    $("#choose td").each(function (i, n) {
                        $(this).html(words[i]);
                    });
                })
            });

            // 鼠标移动
            $("#canvas1").mousemove(function (e) {
                if (isMouseDown) {
                    var canvas = document.getElementById("canvas1");
                    var rect = canvas.getBoundingClientRect();
                    var x = parseInt(e.pageX - rect.left * (canvas.width / rect.width));
                    var y = parseInt(e.pageY - rect.top * (canvas.height / rect.height));
                    if (data == "") {
                        data += x + "," + y;
                    } else {
                        data += "," + x + "," + y;
                    }
                    var context = canvas.getContext("2d");
                    context.fillRect(x, y, 5, 5);
                }
            });

            // 关闭按钮
            $("#close").click(function () {
                //当你在iframe页面关闭自身时
                var index = parent.layer.getFrameIndex(window.name); //先得到当前iframe层的索引
                parent.layer.close(index); //再执行关闭   
            });

            // 清空画布
            $("#rewrite").click(function () {
                var context = document.getElementById("canvas1").getContext("2d");
                context.clearRect(0, 0, 216, 208);
                data = "";
            });

            // 点击单元格中的候选字
            $("#choose td").click(function () {
                var context = document.getElementById("canvas1").getContext("2d");
                context.clearRect(0, 0, 216, 208);
                data = "";
                var word = $(this).html();
                if (word == null || word == "") {
                    return;
                }
                var html = $('#result').html();
                html += word;
                $('#result').html(html);
            });
        })
    </script>
</body>
</html>
