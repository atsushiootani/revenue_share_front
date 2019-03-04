import web3 from '../helper/web3';
import abi from '../helper/abi';

const address = "0x20Edd3b4350c1B5Af4f99DCa29AEf4c5C0473f1E";
const contract = web3.eth.Contract(abi, address);

export default contract;
