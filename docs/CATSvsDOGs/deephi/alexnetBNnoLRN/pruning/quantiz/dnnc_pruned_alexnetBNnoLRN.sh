#!/bin/bash

ML_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && cd ../../../.. && pwd )"
export ML_DIR
$(which dnnc &> /dev/null) || export PATH=$HOME/ML/DNNDK/tools:$PATH
#DNNDK_ROOT=$HOME/ML/DNNDK/tools

net=alexnetBNnoLRN
work_dir=$ML_DIR/deephi/alexnetBNnoLRN/pruning/quantiz
model_dir=${work_dir}/decent_output
output_dir=${work_dir}/dnnc_output

echo "Compiling network: ${net}"

dnnc --prototxt=${model_dir}/deploy.prototxt     \
       --caffemodel=${model_dir}/deploy.caffemodel \
       --output_dir=${output_dir}                  \
       --net_name=${net}                           \
       --dpu=4096FA                                \
       --cpu_arch=arm64                            \
       --mode=debug                                \
       --save_kernel

echo " copying dpu elf file into ../../zcu102/pruned/model/arm64_4096 "
cp ${output_dir}/dpu_${net}\_*.elf  ${output_dir}/../../../zcu102/pruned/model/arm64_4096

#mv ~/ML/${net}_kernel* ${work_dir}/dnnc_output

echo " copying the test images to be used by the ZCU102"
cp -r $ML_DIR/input/jpg/test ${output_dir}/../../../zcu102/test_images
mv $ML_DIR/../${net}_kernel*   ${work_dir}/dnnc_output


cd $ML_DIR/deephi/alexnetBNnoLRN/zcu102/pruned
#force a soft link to the testing images
ln -nsf ../test_images ./test_images
cd $ML_DIR

