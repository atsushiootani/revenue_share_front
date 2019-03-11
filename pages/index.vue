<template>
  <section class="container">
    <div>
      <h1 class="title">
        revenue share contract
      </h1>
      <h2 class="subtitle">
        報酬分配を自動化して、みんなのお金をクリアに！
      </h2>
      <br>
      <h2>プロジェクトの情報</h2>
      <ul>
        <li>参加メンバー数  {{MemberCount}}</li>
        <li>メンバー一覧 {{Members}}</li>
        <li>総貢献度数</li>
        <button type="button" class="btn btn-primary" @click="update_project_info">情報更新</button>
      </ul>
      <br>
      <br>
      <h2>あなたの情報</h2>
      <ul>
        <li>
          address: {{CoinBase}}
        </li>
        <template v-if="IsMember">
          <li>あなたはメンバーです</li>
          <li>
            <input type="text" class="form-control" placeholder="招待したいaddress" v-model="JoinAnotherAddress">
            <button type="button" class="btn btn-primary" @click="request_to_join_another">メンバーに招待する</button>
          </li>
        </template>
        <template v-else>
          <li>あなたはメンバーではありません</li>
          <li>
            <button type="button" class="btn btn-primary" @click="request_to_join">メンバーとして参加する</button>
          </li>
        </template>
      </ul>
      <br>
      <br>
      <h2>プロジェクト外メンバーメニュー</h2>
      <ul>
        このプロジェクトに送金する
        <input type="text" class="form-control" placeholder="ether" v-model="PayAmount">
        <button type="button" class="btn btn-primary" @click="pay_to_project">送金</button>
      </ul>
      <br>
      <br>
      <p>{{Message}}</p>
    </div>
  </section>
</template>

<script>
import AppLogo from '~/components/AppLogo.vue'
//import web3 from '../helper/web3';
//import contractInstance from '../helper/contract';
import abi from '../helper/abi';

var web3;
var contractInstance;

export default {
  data() {
    return {
      Host: "wait..",
      CoinBase: "wait...",
      AccountCount: "0",
      Account0: "wait...",
      IsMember: false,
      MemberCount: 0,
      Members: [],
      PayAmount: "",
      JoinAnotherAddress: "",
      Message: "",
    }
  },
  beforeMount(){
    console.log('window.ethereum: ', window.ethereum);
    console.log('ethereum: ', ethereum);
    web3 = new Web3(window.ethereum);
    console.log('web3:', web3);
    ethereum.enable().then(()=>{
      let contractAddress = "0x8cD9eb6745Bc504850ec7f4175F938076d3a3b6e";
      let MyContract = web3.eth.contract(abi);
      contractInstance = MyContract.at(contractAddress);
      console.log("contractInstance:", contractInstance);
      //contractInstance.options.address = contractAddress;
      console.log("contractInstance:", contractInstance);
      console.log('contractInstance.transactionHash:', contractInstance.transactionHash); //null
      console.log('contractInstance.address:', contractInstance.address); //contractAddress
      this.update_project_info();
    });
  },
  methods: {
    update_project_info(){
      console.log("contract: ", contractInstance);
      contractInstance.amIMember.call((err, result)=>{
        if (err) { console.log(err); }
        else { this.IsMember  = result; }
      });
      contractInstance.members.call(0, (err,result)=>{
        if (err) { console.log(err); }
        else { this.Members = result; }
      });
      contractInstance.memberCount.call((err,result)=>{
        if (err) { console.log(err); }
        else { this.MemberCount = result; }
      });
      contractInstance.membersWaitingForJoin.call(this.JoinAnotherAddress, (err,result)=>{
        if (err) { console.log(err); }
        else { console.log('membersWaitingForJoin', result); }
      });
    },
    request_to_join(){
      console.log("request_to_join: ", contractInstance);
      contractInstance.requestToJoin.sendTransaction({
        value: 0,
        gas: 200000,
        from: "0xcfc6060C859FA123E3860d84868479A5e20F24a3",
      }, (err, transactionHash) =>{
        if (err) { console.log(err); }
        else { this.Message = "参加申請をしました\n" + this.Message; }
      });
    },
    request_to_join_another(){
      console.log('this.JoinAnotherAddress: ', this.JoinAnotherAddress, web3.isAddress(this.JoinAnotherAddress));
      contractInstance.requestToJoinAnother.sendTransaction(this.JoinAnotherAddress, (err, transactionHash) => {
        if (err) { console.log(err); }
        else { this.Message = "参加申請をしました\n" + this.Message; }
      });
    },
    pay_to_project(){
      console.log("pay_to_project: ", contractInstance);
      web3.eth.sendTransaction({
        value: web3.utils.toWei(this.PayAmount.toString(), 'ether'),
        gas:                200000,
        from: "0x9c4E9Ac07D994F1Bf0b6CCADF015544449210C21"
      }, (err, hash) => {
        if (err) { console.log(err); }
        else {
          console.log('txHash: ', hash); //"0xc00d7771c68ee0636beb7e36939f7fc2ec5715fdfd931f9dfd5a407295baf1c2"
        }
      });
    }
  }
}


</script>

<style>
.container {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
}

.title {
  font-family: "Quicksand", "Source Sans Pro", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; /* 1 */
  display: block;
  font-weight: 300;
  font-size: 100px;
  color: #35495e;
  letter-spacing: 1px;
}

.subtitle {
  font-weight: 300;
  font-size: 42px;
  color: #526488;
  word-spacing: 5px;
  padding-bottom: 15px;
}

.links {
  padding-top: 15px;
}
</style>

