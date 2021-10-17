import { writeFileSync } from "fs";

export async function exportEc2PrivateKey(terraformOutput: any) {

    const clientPrivateKey = terraformOutput.ec2_private_key.value;

    writeFileSync(`../../ec2.pem`, clientPrivateKey);

    console.log("EC2 file is written to 'ec2.pem' in the project root.\nUse this key file to connect to EC2 instances");
}
