using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Text;
using System.Net;
using System.IO;

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace HandwritingRecognition.api
{
    /// <summary>
    /// 手写识别服务
    /// </summary>
    public class HWSingleWriting : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            var request = context.Request;
            var response = context.Response;

            // 获取请求参数
            string data = "";
            if (request["data"] == null)
            {
                response.Write(JsonConvert.SerializeObject(new { Code = 300, Msg = "未传递data参数！" }));
                response.End();
                return;
            }
            data = request["data"].ToString();

            // 构造参数
            string url = "http://api.hanvon.com/rt/ws/v1/hand/single?key=4f3926d9-9240-4e1f-aa5c-801657d0508f&code=83b798e7-cd10-4ce3-bd56-7b9e66ace93d";
            byte[] requestData = Encoding.UTF8.GetBytes(data);

            // 构建请求
            HttpWebRequest hwr = (HttpWebRequest)HttpWebRequest.Create(url);
            hwr.Method = "post";
            hwr.ContentType = "application/octet-stream";

            //填充参数
            hwr.ContentLength = requestData.Length;
            Stream requestStream = hwr.GetRequestStream();
            requestStream.Write(requestData, 0, requestData.Length);
            requestStream.Close();

            // 获取数据
            HttpWebResponse hws = (HttpWebResponse)hwr.GetResponse();
            Stream s = hws.GetResponseStream();
            StreamReader sr = new StreamReader(s);
            string base64Data = sr.ReadToEnd();

            // 处理数据
            string resData = Encoding.UTF8.GetString(Convert.FromBase64String(base64Data));
            JObject obj = JsonConvert.DeserializeObject<JObject>(resData);
            string code = obj["code"].ToString();
            string result = obj["result"].ToString();
            string hz = "";
            foreach (var wd in result.Split(','))
            {
                if (string.IsNullOrEmpty(wd))
                {
                    continue;
                }
                if (hz == "")
                {
                    hz += (char)(int.Parse(wd));
                }
                else
                {
                    hz += "," + (char)(int.Parse(wd));
                }
            }
            result = hz;

            // 返回数据
            response.ContentType = "text/plain";
            response.Write(JsonConvert.SerializeObject(new { code = code, result = result }));
            response.End();
            sr.Close();
            s.Close();
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}