# swift-photos-08
> [jed](https://github.com/junu0516), [sally](https://github.com/sally4405)


## 작업 내용 - 2022년 3월 23일
- 스토리보드에 CollectionView 추가 후 Cell 크기 100x100으로 지정
- UINavigationController 적용 후 Photos 타이틀 지정
- PHAsset 프레임워크 사용해서 사진보관함에 있는 이미지 Cell에 표시
- PHCachingImageManager 사용해서 PHAsset에 이미지 request
- 사진 보관함 변경 시 옵저버로 Alert 메시지 받도록 메소드 정의

## 결과물

|PHImageManager|PHCachingImageManager|
|---|---|
|<img width="252" src="https://user-images.githubusercontent.com/45891045/159649923-c8958504-0a10-434b-92de-f44edf1b1362.png">|<img width="247" src="https://user-images.githubusercontent.com/45891045/159649905-6501e736-f25a-4b92-8af0-05970d5b1b08.png">|

|사진 권한 획득 및 전체 결과|옵저버가 변화 감지하는 것 확인|
|---|---|
|<img width="366" src="https://user-images.githubusercontent.com/45891045/159650147-31e1566e-408e-42b5-bd55-7a690cc8d6db.gif">|<img width="366" src="https://user-images.githubusercontent.com/45891045/159650108-238b0827-246b-45ff-802f-697ff7cafb85.png">|

## 고민과 해결과정

- PHAssetCollection이 처음에는 사진 혹은 비디오 같은 개별 콘텐츠 하나에 대응되는 줄 알았으나, 다시 학습한 후 이것이 앨범 하나에 대응되는 개념인 것으로 이해
- PHAssetCollection 내부에 있는 PHAsset의 개수 만큼 collectionView 메소드가 호출되는 것과 indexPath 변수의 의미를 확인

- 사진을 최근 날짜 순으로 정렬하기 위해 PHFetchOptions 활용
- PHImageManager과 PHCachingImageManager 사용의 차이를 알고자, 실행시간을 비교해서 사진 1만장 정도 있을 때 약 0.1초의 차이가 발생하는 것 확인