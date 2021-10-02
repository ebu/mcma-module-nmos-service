import * as fs from "fs";
import * as AWS from "aws-sdk";
import { exportVpnClientConfig } from "./export-vpn-client-config";

const TERRAFORM_OUTPUT = "../../deployment/terraform.output.json";

const { AwsProfile, AwsRegion } = process.env;

const credentials = new AWS.SharedIniFileCredentials({ profile: AwsProfile });
AWS.config.credentials = credentials;
AWS.config.region = AwsRegion;

async function main() {
    try {
        const terraformOutput = JSON.parse(fs.readFileSync(TERRAFORM_OUTPUT, "utf8"));

        await exportVpnClientConfig(terraformOutput, new AWS.EC2());
    } catch (error) {
        if (error.response && error.response.data) {
            console.error(JSON.stringify(error.response.data, null, 2));
        } else {
            console.error(error);
        }
    }
}

main().then(() => console.log("Done"));
