#!/usr/bin/env bash

# 压测脚本模板中设定的压测时间应为20秒
# 定义基础变量
export jmx_template="iInterface"
export suffix=".jmx"
# 定义模版的文件名
export jmx_template_filename="${jmx_template}${suffix}"
# 定义os_type对象，该对象是一个命令，运行uname后可以返回系统的这样的一个名字
export os_type=$(uname)

# 需要在系统变量中定义jmeter根目录的位置，如下
# export jmeter_path="/your jmeter path/"
#export jmeter_path="/usr"
export jmeter_path="/Applications/apache-jmeter-5.4.3"

echo "自动化压测开始"

# 压测并发数列表
thread_number_array=(10 20 30)
# 标准shell代码for循环
for num in "${thread_number_array[@]}"; do
  # 生成对应压测线程的jmx文件
  export jmx_filename="${jmx_template}_${num}${suffix}"
  export jtl_filename="test_${num}.jtl"
  export web_report_path_name="web_${num}"

  # 清理环境
  rm -f ${jmx_filename} ${jtl_filename}
  rm -rf ${web_report_path_name}

  cp ${jmx_template_filename} ${jmx_filename}
  echo "生成jmx压测脚本 ${jmx_filename}"

  # linux三剑客，sed替换设置并发数量
  if [[ "${os_type}" == "Darwin" ]]; then
    # Mac系统对应命令
    sed -i "" "s/thread_num/${num}/g" ${jmx_filename}
  else
    # 其他系统对应命令
    sed -i "s/thread_num/${num}/g" ${jmx_filename}
  fi

  # JMeter 静默压测
  ${jmeter_path}/bin/jmeter -n -t ${jmx_filename} -l ${jtl_filename}

  # 生成Web压测报告
  ${jmeter_path}/bin/jmeter -g ${jtl_filename} -e -o ${web_report_path_name}

  rm -f ${jmx_filename} ${jtl_filename}
done
echo "自动化压测全部结束"
