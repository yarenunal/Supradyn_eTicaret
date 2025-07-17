const axios = require('axios');

const products = [
  {
    "name": "Mavi Tişört",
    "description": "Oversize kesim",
    "price": 176.88,
    "stock": 43,
    "imageUrl": "https://sky-static.mavi.com/mnresize/1430/2028/066842-70758_image_1.jpg",
    "category": "Giyim"
  },
  {
    "name": "Siyah Sweatshirt",
    "description": "%100 pamuk",
    "price": 210.72,
    "stock": 23,
    "imageUrl": "https://static.ticimax.cloud/55900/uploads/urunresimleri/buyuk/cetinkaya-mentality-3035-3-iplik-kapus-3-ae6a.jpg",
    "category": "Giyim"
  },
  {
    "name": "Kot Pantolon",
    "description": "Günlük kullanım için ideal",
    "price": 490.27,
    "stock": 30,
    "imageUrl": "https://static.ticimax.cloud/cdn-cgi/image/width=-,quality=85/4197/uploads/urunresimleri/buyuk/setreacik-mavi-belde-dugme-detayli-kot-9ec-b7.jpg",
    "category": "Giyim"
  },
  {
    "name": "Kırmızı Elbise",
    "description": "Yüksek kaliteli dikiş",
    "price": 412.33,
    "stock": 7,
    "imageUrl": "https://dfcdn.defacto.com.tr/7/C4365AX_24SP_RD335_01_01.jpg",
    "category": "Giyim"
  },
  {
    "name": "Haki Ceket",
    "description": "Nefes alabilir kumaş",
    "price": 458.7,
    "stock": 35,
    "imageUrl": "http://cdn.dsmcdn.com/ty1519/product/media/images/prod/QC/20240826/15/8b94cac5-0e50-39ef-96c6-b8422520e742/1_org_zoom.jpg",
    "category": "Giyim"
  },
  {
    "name": "Lacivert Ceket",
    "description": "Yumuşak dokulu",
    "price": 179.5,
    "stock": 35,
    "imageUrl": "https://cdn.beymen.com/mnresize/505/704/productimages/b1c3p0t1.o4i_IMG_01_8683798529292.jpg",
    "category": "Giyim"
  },
  {
    "name": "Şort",
    "description": "Yıkanabilir ve dayanıklı",
    "price": 467.09,
    "stock": 32,
    "imageUrl": "https://cdn.myikas.com/images/28864072-1728-4c41-a60f-7e46390d0b7c/c9945027-f514-4fde-b6c9-b552496409fa/image_1080.jpg",
    "category": "Giyim"
  },
  {
    "name": "Gömlek",
    "description": "Günlük kullanım için ideal",
    "price": 427.76,
    "stock": 33,
    "imageUrl": "https://floimages.mncdn.com/media/catalog/product/24-06/11/201240798-1-1718116198.jpg",
    "category": "Giyim"
  },
  {
    "name": "Beyaz Bluz",
    "description": "Yüksek kaliteli dikiş",
    "price": 375.73,
    "stock": 12,
    "imageUrl": "https://static.ticimax.cloud/cdn-cgi/image/width=-,quality=85/55981/uploads/urunresimleri/buyuk/mastery-ip-detayli-uzun-kollu-beyaz-bl-00a52c.jpg",
    "category": "Giyim"
  },
  {
    "name": "Deri Ceket",
    "description": "Yumuşak dokulu",
    "price": 380.37,
    "stock": 38,
    "imageUrl": "https://akn-desa.a-cdn.akinoncloud.com/products/2023/11/21/228533/9cfe9171-79c5-480c-bd10-d527d26ebb09_size1500x1500_quality100_cropCenter.jpg",
    "category": "Giyim"
  },
  {
    "name": "Oversize Tişört",
    "description": "Soğuk havalarda sıcak tutar",
    "price": 274.94,
    "stock": 24,
    "imageUrl": "https://cdn.swist.com.tr/beyaz-brooklyn-baskili-oversize-kadin-tshirt-tisort-swist-29245-17-B.jpg",
    "category": "Giyim"
  },
  {
    "name": "Yazlık Elbise",
    "description": "Rahat ve şık tasarım",
    "price": 223.86,
    "stock": 13,
    "imageUrl": "https://images.pexels.com/photos/1002640/pexels-photo-1002640.jpeg",
    "category": "Giyim"
  }
];

async function addProducts() {
  for (const product of products) {
    try {
      const res = await axios.post('http://localhost:3000/api/products', product);
      console.log('Eklendi:', res.data.product.name);
    } catch (err) {
      console.error('Hata:', product.name, err.response?.data || err.message);
    }
  }
}

addProducts(); 