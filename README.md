# swift-photos-08
> [jed](https://github.com/junu0516), [sally](https://github.com/sally4405)


## 작업 내용

### 카메라롤 이미지 가져오기
- PHAsset 프레임워크 사용해서 사진보관함에 있는 이미지 Cell에 표시
- PHCachingImageManager 사용해서 PHAsset에 이미지 request
- 사진 보관함 변경 시 옵저버로 Alert 메시지 받도록 메소드 정의

### 이미지 다운로드
- local에 JSON 파일 다운로드 후 프로젝트에 추가
- +버튼 누르면 CollectionViewController에서 상속받은 새로운 DoodleViewController 표시
- DispatchQueue 활용해서 여러 이미지 보여주기
- urlSession 사용하여 이미지 다운로드

### 사진 저장하기 및 편집하기
- longPressGesture 적용하여 선택된 셀에 UIMenuItem 띄우고 저장 기능 구현
- 이미지 1개 이상 선택시 edit 버튼 활성화
- edit 버튼 클릭시 선택된 이미지에 옵션(효과주기, 되돌리기) 주기


## 결과물

|사진 권한 획득|구현 결과물|
|---|---|
|<img width="360" src="https://user-images.githubusercontent.com/45891045/159650147-31e1566e-408e-42b5-bd55-7a690cc8d6db.gif">|<img width="360" src="https://user-images.githubusercontent.com/45891045/161375746-009427b7-9105-498f-9d33-23bdf065797b.gif">|


## 고민과 해결과정

- PHAssetCollection이 처음에는 사진 혹은 비디오 같은 개별 콘텐츠 하나에 대응되는 줄 알았으나, 다시 학습한 후 이것이 앨범 하나에 대응되는 개념인 것으로 이해
- PHAssetCollection 내부에 있는 PHAsset의 개수 만큼 collectionView 메소드가 호출되는 것과 indexPath 변수의 의미를 확인

- 사진을 최근 날짜 순으로 정렬하기 위해 PHFetchOptions 활용
- PHImageManager과 PHCachingImageManager 사용의 차이를 알고자, 실행시간을 비교해서 사진 1만장 정도 있을 때 약 0.1초의 차이가 발생하는 것 확인


## 현재의 문제상황

- 선택된 셀의 border를 selectedBackgroundView를 활용하지 않고 layer.border 속성을 활용중
- 사진 편집 후 다른 셀이 선택되는 것처럼 테두리가 표시됨 (실제로 선택은 안되고 있는 상태)
- 사진 편집 시 이미지 크기가 크면 오류 발생 (아이폰 기본 이미지들)
- 여러 사진 편집 시 observer가 alert를 여러개 동시에 띄우려고 해서 경고 출력됨
