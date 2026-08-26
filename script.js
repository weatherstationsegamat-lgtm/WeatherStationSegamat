const T={
en:{
live:"Live Weather",info:"Weather Information",location:"Sungai Segamat, Johor",liveNow:"LIVE",
headerMessage:"Monitoring today, protecting tomorrow.",headerSub:"Real-time weather information for a healthier and safer community.",
fundedShort:"Funded by",collabShort:"In collaboration with",temperature:"TEMPERATURE",feels:"Feels like",
humidity:"HUMIDITY",rain:"RAINFALL",wind:"WIND",heatIndex:"FEELS-LIKE TEMP",direction:"Direction",
partly:"Current",heatAlert:"Heat awareness",heatAlertText:" Stay hydrated and take regular breaks.",
moderate:"Moderate",today:"Today",hot:"Hot",trend:"TEMPERATURE TREND (TODAY)",
communitySafety:"COMMUNITY HEALTH & SAFETY",hydrate:"Stay Hydrated",hydrateText:"Drink plenty of water throughout the day.",
cool:"Stay Cool",coolText:"Seek shade and stay in cool areas.",sun:"Sun Protection",sunText:"Wear a hat, sunglasses and sunscreen.",
others:"Check on Others",othersText:"Look out for children, elderly and vulnerable people.",
signs:"Know the signs of heat stress: headache, dizziness, nausea, heavy sweating.",learn:"Learn More ›",
forecast:"FORECAST OVERVIEW",partlyCloudy:"Partly Cloudy",stationInfo:"STATION INFORMATION",
stationStatus:"Station Status",online:"ONLINE",updated:"Last Updated",locationLabel:"Location",
refresh:"Updates automatically",everyFive:"Every minute",fundedBy:"The project is funded by:",
collab:"In collaboration with:",footerText:"Heat Risk Awareness and Technology-driven Care for Community Health",
dataNote:"This website provides real-time weather information for Weather Station Sungai Segamat for community use.",
updatedEvery:"Updated every minute.",aboutStation:"About This Station",healthSafety:"Health & Safety",
whatItMeans:"WHAT IT MEANS",whyMatters:"Why it matters",
tempWhy:"Higher temperatures can increase heat strain, especially outdoors.",
humidityWhy:"High humidity can make hot weather feel more uncomfortable.",
rainWhy:"Rainfall helps us understand recent local weather conditions.",
windWhy:"Wind affects how warm or comfortable outdoor conditions feel.",
heatGuide:"When the weather feels hot",
heatGuideText:"Use the live readings as a simple guide and take sensible steps to stay comfortable and hydrated.",
historyNote:"Trend visualisation",now:"Now",trendLabel:"TODAY",infoLabel:"WEATHER INFORMATION",
understand:"Understanding the Weather",intro:"Simple information to help the community understand weather conditions.",
communityLabel:"COMMUNITY",simpleTitle:"Weather made simple",simpleText:"Learn what each weather measurement means and why it matters.",
heatRisk:"Heat risk",low:"Low",high:"High",veryHigh:"Very high",comfortable:"Comfortable",
weatherUnavailable:"Weather data unavailable",rainChance:"Rain chance",windDir:"Wind direction"
},
ms:{
live:"Cuaca Semasa",info:"Maklumat Cuaca",location:"Sungai Segamat, Johor",liveNow:"LANGSUNG",
headerMessage:"Memantau hari ini, melindungi hari esok.",headerSub:"Maklumat cuaca masa nyata untuk komuniti yang lebih sihat dan selamat.",
fundedShort:"Dibiayai oleh",collabShort:"Dengan kerjasama",temperature:"SUHU",feels:"Terasa seperti",
humidity:"KELEMBAPAN",rain:"HUJAN",wind:"ANGIN",heatIndex:"SUHU TERASA",direction:"Arah",
partly:"Semasa",heatAlert:"Kesedaran haba",heatAlertText:" Minum air yang mencukupi dan berehat secara berkala.",
moderate:"Sederhana",today:"Hari ini",hot:"Panas",trend:"TREND SUHU (HARI INI)",
communitySafety:"KESIHATAN & KESELAMATAN KOMUNITI",hydrate:"Kekal Terhidrat",hydrateText:"Minum air secukupnya sepanjang hari.",
cool:"Kekal Sejuk",coolText:"Cari tempat teduh dan kekal di kawasan yang sejuk.",sun:"Perlindungan Matahari",
sunText:"Pakai topi, cermin mata hitam dan pelindung matahari.",others:"Periksa Orang Lain",
othersText:"Beri perhatian kepada kanak-kanak, warga emas dan individu yang terdedah.",
signs:"Kenali tanda tekanan haba: sakit kepala, pening, loya dan berpeluh banyak.",learn:"Ketahui Lebih Lanjut ›",
forecast:"GAMBARAN RAMALAN",partlyCloudy:"Berawan Sebahagian",stationInfo:"MAKLUMAT STESEN",
stationStatus:"Status Stesen",online:"DALAM TALIAN",updated:"Kemaskini Terakhir",locationLabel:"Lokasi",
refresh:"Dikemas kini secara automatik",everyFive:"Setiap minit",fundedBy:"Projek ini dibiayai oleh:",
collab:"Dengan kerjasama:",footerText:"Kesedaran Risiko Haba dan Penjagaan Berasaskan Teknologi untuk Kesihatan Komuniti",
dataNote:"Laman ini menyediakan maklumat cuaca masa nyata untuk Stesen Cuaca Sungai Segamat bagi kegunaan komuniti.",
updatedEvery:"Dikemas kini setiap minit.",aboutStation:"Tentang Stesen Ini",healthSafety:"Kesihatan & Keselamatan",
whatItMeans:"MAKSUDNYA",whyMatters:"Mengapa penting",
tempWhy:"Suhu yang lebih tinggi boleh meningkatkan tekanan haba, terutama di luar.",
humidityWhy:"Kelembapan tinggi boleh menyebabkan cuaca panas terasa lebih tidak selesa.",
rainWhy:"Hujan membantu kita memahami keadaan cuaca tempatan terkini.",
windWhy:"Angin mempengaruhi bagaimana keadaan luar terasa panas atau selesa.",
heatGuide:"Apabila cuaca terasa panas",
heatGuideText:"Gunakan bacaan semasa sebagai panduan ringkas dan ambil langkah yang sesuai untuk kekal selesa serta terhidrat.",
historyNote:"Visualisasi trend",now:"Sekarang",trendLabel:"HARI INI",infoLabel:"MAKLUMAT CUACA",
understand:"Memahami Cuaca",intro:"Maklumat ringkas untuk membantu komuniti memahami keadaan cuaca.",
communityLabel:"KOMUNITI",simpleTitle:"Cuaca lebih mudah difahami",simpleText:"Ketahui maksud setiap ukuran cuaca dan mengapa ia penting.",
heatRisk:"Risiko haba",low:"Rendah",high:"Tinggi",veryHigh:"Sangat tinggi",comfortable:"Selesa",
weatherUnavailable:"Data cuaca tidak tersedia",rainChance:"Kebarangkalian hujan",windDir:"Arah angin"
}
};

let currentLang=localStorage.getItem("heatcareLang")||"en";
let lastWeather=null,lastForecast=null;

const LATITUDE=2.5127;
const LONGITUDE=102.8158;
const API=`https://api.open-meteo.com/v1/forecast?latitude=${LATITUDE}&longitude=${LONGITUDE}&timezone=Asia%2FKuala_Lumpur&current=temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m,apparent_temperature,wind_direction_10m&hourly=temperature_2m,apparent_temperature,precipitation_probability,relative_humidity_2m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum&forecast_days=7`;

const weatherCode={
0:["Clear sky","Langit cerah","☀️"],1:["Mainly clear","Cerah berawan","🌤️"],2:["Partly cloudy","Berawan sebahagian","⛅"],
3:["Overcast","Mendung","☁️"],45:["Fog","Kabus","🌫️"],48:["Depositing rime fog","Kabus","🌫️"],
51:["Light drizzle","Renyai ringan","🌦️"],53:["Drizzle","Hujan renyai","🌦️"],55:["Dense drizzle","Renyai lebat","🌧️"],
61:["Slight rain","Hujan ringan","🌦️"],63:["Rain","Hujan","🌧️"],65:["Heavy rain","Hujan lebat","🌧️"],
71:["Slight snow","Salji ringan","🌨️"],73:["Snow","Salji","🌨️"],75:["Heavy snow","Salji lebat","❄️"],
80:["Rain showers","Hujan sebentar","🌦️"],81:["Rain showers","Hujan sebentar","🌧️"],82:["Heavy rain showers","Hujan lebat","🌧️"],
95:["Thunderstorm","Ribut petir","⛈️"],96:["Thunderstorm with hail","Ribut petir + hujan batu","⛈️"],99:["Thunderstorm with hail","Ribut petir + hujan batu","⛈️"]
};

function lang(x){
  currentLang=x;
  document.documentElement.lang=x;
  document.querySelectorAll("[data-t]").forEach(e=>{
    if(T[x][e.dataset.t]!==undefined)e.textContent=T[x][e.dataset.t];
  });
  document.querySelectorAll("[data-lang]").forEach(b=>b.classList.toggle("active",b.dataset.lang===x));
  localStorage.setItem("heatcareLang",x);
  if(lastWeather)renderWeather(lastWeather);
  if(lastForecast)renderForecast(lastForecast);
}
document.querySelectorAll("[data-lang]").forEach(b=>b.onclick=()=>lang(b.dataset.lang));
lang(currentLang);

function condition(apparent){
  if(apparent>=38)return{en:"VERY HIGH",ms:"SANGAT TINGGI",icon:"🔥",level:"very-high"};
  if(apparent>=35)return{en:"HIGH",ms:"TINGGI",icon:"🥵",level:"high"};
  if(apparent>=32)return{en:"MODERATE",ms:"SEDERHANA",icon:"☀️",level:"moderate"};
  return{en:"LOW",ms:"RENDAH",icon:"🌿",level:"low"};
}

function fmtTime(value){
  return new Date(value).toLocaleTimeString(currentLang==="ms"?"ms-MY":"en-MY",{hour:"2-digit",minute:"2-digit"});
}
function fmtDay(value){
  return new Date(value+"T00:00:00").toLocaleDateString(currentLang==="ms"?"ms-MY":"en-MY",{weekday:"short"});
}
function weatherText(code){
  const x=weatherCode[code]||weatherCode[0];
  return currentLang==="ms"?x[1]:x[0];
}
function weatherIcon(code){
  return (weatherCode[code]||weatherCode[0])[2];
}

function renderWeather(c){
  lastWeather=c;
  const t=Number(c.temperature_2m),h=Number(c.relative_humidity_2m),r=Number(c.precipitation);
  const w=Number(c.wind_speed_10m),f=Number(c.apparent_temperature);
  const q=condition(f);

  const set=(id,value)=>{const e=document.getElementById(id);if(e)e.textContent=value};
  set("temperature",t.toFixed(1)+"°C");
  set("feelsLike",f.toFixed(1)+"°C");
  set("humidity",Math.round(h)+"%");
  set("rainfall",r.toFixed(1)+" mm");
  set("wind",w.toFixed(1)+" km/h");
  set("windDirection",Math.round(c.wind_direction_10m));
  set("heatIndex",f.toFixed(1)+"°C");
  set("condition",currentLang==="ms"?q.ms:q.en);
  set("conditionIcon",q.icon);
  set("updatedTime",fmtTime(c.time));
  set("chartTemp",t.toFixed(1)+"°C");
  set("chartTime",fmtTime(c.time));

  const risk=document.getElementById("heatRiskValue");
  if(risk)risk.textContent=(currentLang==="ms"?q.ms:q.en);
  const riskIcon=document.getElementById("heatRiskIcon");
  if(riskIcon)riskIcon.textContent=q.icon;
  const heatCard=document.querySelector(".heat-index");
  if(heatCard)heatCard.dataset.risk=q.level;
}

function renderForecast(data){
  lastForecast=data;
  const row=document.getElementById("forecastRow");
  if(!row)return;
  row.innerHTML="";
  const days=data.daily.time;
  days.slice(0,7).forEach((date,i)=>{
    const code=data.daily.weather_code[i];
    const min=Math.round(data.daily.temperature_2m_min[i]);
    const max=Math.round(data.daily.temperature_2m_max[i]);
    const rain=Math.round(data.daily.precipitation_probability_max[i]??0);
    const card=document.createElement("div");
    card.className="forecast-day"+(i===0?" today":"");
    card.innerHTML=`
      <b>${i===0?(currentLang==="ms"?"Hari ini":"Today"):fmtDay(date)}</b>
      <span>${weatherIcon(code)}</span>
      <strong>${min}° / ${max}°C</strong>
      <small>${weatherText(code)}</small>
      <em>${T[currentLang].rainChance}: ${rain}%</em>`;
    row.appendChild(card);
  });
}

function renderTrend(data){
  const chart=document.querySelector(".big-chart");
  if(!chart)return;

  const today=new Date().toLocaleDateString("en-CA",{timeZone:"Asia/Kuala_Lumpur"});
  const times=data.hourly.time;
  const temps=data.hourly.temperature_2m;
  const currentHour=new Date().getHours();

  // Build 8 points for 00,03,06,...21 using today's hourly forecast.
  const points=[];
  for(let hour=0;hour<24;hour+=3){
    const idx=times.findIndex(t=>t.startsWith(today+"T"+String(hour).padStart(2,"0")+":00"));
    if(idx>=0)points.push({hour,temp:Number(temps[idx])});
  }
  if(points.length<2)return;

  const values=points.map(p=>p.temp);
  const min=Math.floor(Math.min(...values)-2);
  const max=Math.ceil(Math.max(...values)+2);
  const range=Math.max(1,max-min);

  let svg=chart.querySelector(".trend-svg");
  if(!svg){
    svg=document.createElementNS("http://www.w3.org/2000/svg","svg");
    svg.classList.add("trend-svg");
    svg.setAttribute("viewBox","0 0 800 240");
    svg.setAttribute("preserveAspectRatio","none");
    chart.appendChild(svg);
  }

  const coords=points.map((p,i)=>{
    const x=20+(i/(points.length-1))*755;
    const y=205-((p.temp-min)/range)*165;
    return [x,y];
  });
  const line=coords.map(p=>p.join(",")).join(" ");
  const area=`M ${coords[0][0]} ${coords[0][1]} `+
    coords.slice(1).map(p=>`L ${p[0]} ${p[1]}`).join(" ")+
    ` L ${coords.at(-1)[0]} 205 L ${coords[0][0]} 205 Z`;

  svg.innerHTML=`
    <defs>
      <linearGradient id="trendFill" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0%" stop-color="#f0a143" stop-opacity=".28"/>
        <stop offset="100%" stop-color="#f0a143" stop-opacity="0"/>
      </linearGradient>
    </defs>
    <path d="${area}" fill="url(#trendFill)"></path>
    <polyline points="${line}" fill="none" stroke="#ed8a24" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"></polyline>
    ${coords.map((p,i)=>`<circle cx="${p[0]}" cy="${p[1]}" r="4" fill="#fff" stroke="#ed8a24" stroke-width="3"><title>${points[i].hour}:00 — ${points[i].temp.toFixed(1)}°C</title></circle>`).join("")}
  `;

  const ylabels=chart.querySelector(".ylabels");
  if(ylabels){
    ylabels.innerHTML=[max,Math.round(max-range*.25),Math.round(max-range*.5),Math.round(max-range*.75),min]
      .map(v=>`<span>${v}</span>`).join("");
  }
}

async function loadWeather(){
  try{
    const response=await fetch(API,{cache:"no-store"});
    if(!response.ok)throw Error("API");
    const data=await response.json();
    renderWeather(data.current);
    renderForecast(data);
    renderTrend(data);

    const status=document.querySelector(".status-bar .online");
    if(status){
      status.classList.remove("offline");
      status.innerHTML=`● <span data-t="online">${T[currentLang].online}</span>`;
    }
  }catch(e){
    console.error(e);
    const el=document.getElementById("condition");
    if(el)el.textContent=T[currentLang].weatherUnavailable;
    const status=document.querySelector(".status-bar .online");
    if(status){
      status.classList.add("offline");
      status.textContent="● OFFLINE";
    }
  }
}

if(document.getElementById("temperature")){
  loadWeather();
  setInterval(loadWeather,60000);
}
