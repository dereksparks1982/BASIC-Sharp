#!/usr/bin/env node
// Independent source-to-BSIR entrypoint: Node only; no Ruby.
import {readFileSync,writeFileSync} from 'node:fs';
import {compile} from './bsharp_compiler.mjs';
const args=process.argv.slice(2);
if(!args.length||args.includes('--help')){
 console.log('Usage: node compiler/portable/bsharp_cli.mjs source.bsharp [--out output.bsir.json]');
 process.exit(args.includes('--help')?0:64);
}
try{
 if(!args[0].endsWith('.bsharp'))throw Error('Expected a .bsharp file');
 if(args.length!==1&&!(args.length===3&&args[1]==='--out'&&args[2].endsWith('.bsir.json')))
   throw Error('Invalid output arguments');
 const result=JSON.stringify(compile(readFileSync(args[0],'utf8')),null,2)+'\n';
 if(args.length===3){writeFileSync(args[2],result,{flag:'wx'});console.log('Wrote '+args[2]);}
 else process.stdout.write(result);
}catch(error){console.error(error.message);process.exitCode=1;}
