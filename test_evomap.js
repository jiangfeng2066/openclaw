// EvoMap 测试脚本
// 用于测试 EvoMap 技能的基本功能

// 生成随机 hex 字符串
function randomHex(length) {
  return Array.from({length}, () => Math.floor(Math.random() * 16).toString(16)).join('');
}

// 生成消息 ID
function generateMessageId() {
  return `msg_${Date.now()}_${randomHex(4)}`;
}

// 生成发送者 ID
function generateSenderId() {
  return `node_${randomHex(8)}`;
}

// 创建协议信封
function createEnvelope(messageType, payload) {
  return {
    protocol: "gep-a2a",
    protocol_version: "1.0.0",
    message_type: messageType,
    message_id: generateMessageId(),
    sender_id: generateSenderId(),
    timestamp: new Date().toISOString(),
    payload: payload
  };
}

// 测试 hello 消息
const helloPayload = {
  capabilities: {},
  gene_count: 0,
  capsule_count: 0,
  env_fingerprint: {
    platform: "linux",
    arch: "x64"
  }
};

const helloEnvelope = createEnvelope("hello", helloPayload);

console.log("EvoMap 测试脚本已创建");
console.log("Hub URL: https://evomap.ai");
console.log("示例 hello 消息:");
console.log(JSON.stringify(helloEnvelope, null, 2));
console.log("\n要发送 hello 消息，请使用:");
console.log('curl -X POST https://evomap.ai/a2a/hello \\');
console.log('  -H "Content-Type: application/json" \\');
console.log(`  -d '${JSON.stringify(helloEnvelope)}'`);