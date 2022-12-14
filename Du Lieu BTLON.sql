CREATE DATABASE QuanLyBanHang_NamNhac
Use QuanLyBanHang_NamNhac
go

create table Cap_Nhat_Kho
(
	Ngay date,
	MaHang varchar(5),
	TenHang nvarchar(100),
	TinhTrang nvarchar(20),
	SoLuong int,
	DonGia numeric (12,0),
	DonViTinh nvarchar(20),
	DoanhThu numeric (12,0),
	PRIMARY KEY (MaHang)
)
go

create table Kho
(
	MaHang varchar(5),
	TenHang nvarchar(100),
	GiaBan numeric (12,0),
	SoLuongTon int,
	PRIMARY KEY (MaHang),
	foreign key (MaHang) references Cap_Nhat_Kho
)
go

create table DonBan
(
    MaDonBan int,
    HoTen nvarchar(100),
    SoDT varchar(10),
	MaHang varchar(5),
    TenHang nvarchar(100),
	SoLuong int,
	ThanhTien numeric(12,0),
    ThoiGian date,
    TrangThai varchar(20),
    primary key (MaDonBan),
    foreign key (MaHang) references Kho,
)
go

Create table KhachHang(
	MaKhachHang varchar(5),
	MaDonBan int,
	HoTen nvarchar(100),
	SoDR varchar(10),
	TrangThai varchar(20)
	primary key (MaKhachHang),
	foreign key (MaDonBan) references DonBan
)

create table KhachHang_Chua_Thanh_Toan
(
	MaKhachHang varchar(5),
	MaHoaDon int,
	SoDT varchar(10),
	SoTien numeric(12,0),
	primary key(MaKhachHang),
	foreign key (MaKhachHang) references KhachHang
)
go

--Cap_Nhat_Kho
CREATE TRIGGER TRIG_XuatNhap_Kho
on Cap_Nhat_Kho
instead of insert
AS
BEGIN
    DECLARE @Ngay date,
            @TenHang nvarchar(100),
            @TinhTrang nvarchar(20),
            @SoLuong int,
            @DonGia numeric (12,0),
            @DoanhThu numeric (12,0),
            @MaHang varchar(5),
            @MaHang_new varchar(5),
            @DonViTinh nvarchar(20)
    select @TenHang = TenHang,
           @SoLuong = SoLuong,
           @DonGia = DonGia,
           @Ngay = Ngay,
           @TinhTrang = TinhTrang,
           @DoanhThu = DoanhThu,
           @MaHang = MaHang,
           @DonViTinh = DonViTinh from inserted
    IF exists (select * from inserted)
        BEGIN
            SET @Ngay = getdate()
            Set @DoanhThu = @DonGia * @SoLuong
            if not exists (select MaHang from Cap_Nhat_Kho)
                BEGIN   
                    Set @MaHang_new = '00001'
                End
            Else IF exists (select MaHang from Cap_Nhat_Kho)
                BEGIN
                    SET @TinhTrang = (select TinhTrang from inserted)
                    SET @MaHang = (select max(MaHang) + 1 from Cap_Nhat_Kho )
                    SET @MaHang_new = REPLICATE('0',5 - len (@MaHang)) + @MaHang
                END              
        END
    IF @TenHang in (select TenHang from Cap_Nhat_Kho)
        BEGIN
            IF @TinhTrang = '0'
                BEGIN
                    UPDATE Cap_Nhat_Kho
                    SET Cap_Nhat_Kho.SoLuong = Cap_Nhat_Kho.SoLuong + @SoLuong
                    where @TenHang = Cap_Nhat_Kho.TenHang

                    UPDATE Kho
                    SET Kho.SoLuongTon = Kho.SoLuongTon + @SoLuong
                    where @TenHang = TenHang

                    UPDATE Cap_Nhat_Kho
                    SET DoanhThu = @DonGia * Cap_Nhat_Kho.SoLuong
                    where @TenHang = Cap_Nhat_Kho.TenHang

                    UPDATE Cap_Nhat_Kho
                    SET TinhTrang = N'Vừa Nhập Thêm Hàng'
                    where @TenHang = Cap_Nhat_Kho.TenHang

                END
            ELSE iF @TinhTrang = '1'
                BEGIN
                    UPDATE Cap_Nhat_Kho
                    SET Cap_Nhat_Kho.SoLuong = Cap_Nhat_Kho.SoLuong - @SoLuong
                    where @TenHang = Cap_Nhat_Kho.TenHang
                    
                    UPDATE Kho
                    SET Kho.SoLuongTon = Kho.SoLuongTon - @SoLuong
                    where @TenHang = TenHang

                    UPDATE Cap_Nhat_Kho
                    SET DoanhThu = @DonGia * Cap_Nhat_Kho.SoLuong
                    where @TenHang = Cap_Nhat_Kho.TenHang

                    UPDATE Cap_Nhat_Kho
                    SET TinhTrang = N'Vừa Xuất Hàng'
                    where @TenHang = Cap_Nhat_Kho.TenHang

                END
            return 
        END 
    ELSE 
        BEGIN
            SET @TinhTrang = N'Hàng Mới'
        END

    insert into Cap_Nhat_Kho values (@Ngay,@MaHang_new,@TenHang,@TinhTrang,@SoLuong,@DonGia,@DonViTinh,@DoanhThu)
    insert into Kho values (@MaHang_new,@TenHang,@DonGia,@SoLuong)
END



insert into Cap_Nhat_Kho values(null,null, N'Búa Su','0',20,28000,'cây',null)
insert into Cap_Nhat_Kho values(null,null, N'Búa tạ','0',20,50000,'cây',null)
insert into Cap_Nhat_Kho values(null,null, N'Búa đinh','0',20,25000,'cây',null)
insert into Cap_Nhat_Kho values(null,null, N'Đinh thép 1F','0',20,55000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'Đinh thép 2F','0',20,55000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'Đinh thép 3F','0',20,55000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'Đinh thép 4F','0',20,55000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'Đinh thép 5F','0',20,55000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'Vít đen 2F','0',20,47000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'Vít đen 3F','0',20,47000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'Vít đen 4F','0',20,47000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'Vít đen 5F','0',20,47000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'Vít đen 6F','0',20,47000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'Ống nhựa bình minh 21','0',30,33000,'cây',null)
insert into Cap_Nhat_Kho values(null,null, N'Ống nhựa bình minh 27','0',30,45000,'cây',null)
insert into Cap_Nhat_Kho values(null,null, N'Ống nhựa bình minh 34','0',20,64000,'cây',null)
insert into Cap_Nhat_Kho values(null,null, N'Ống nhựa bình minh 42','0',15,83000,'cây',null)
insert into Cap_Nhat_Kho values(null,null, N'Ống nhựa bình minh 49','0',15,103000,'cây',null)
insert into Cap_Nhat_Kho values(null,null, N'Ống nhựa bình minh 60','0',15,115000,'cây',null)
insert into Cap_Nhat_Kho values(null,null, N'Ống nhựa bình minh 90','0',5,235000,'cây',null)
insert into Cap_Nhat_Kho values(null,null, N'Ống nhựa bình minh 114','0',5,356000,'cây',null)
insert into Cap_Nhat_Kho values(null,null, N'Sơn nước','0',50,110000,'lon',null)
insert into Cap_Nhat_Kho values(null,null, N'Sơn dầu','0',50,250000,'lon',null)
insert into Cap_Nhat_Kho values(null,null, N'Sơn trong nhà','0',10,200000,'thùng',null)
insert into Cap_Nhat_Kho values(null,null, N'Sơn ngoài trời','0',20,110000,'thùng',null)
insert into Cap_Nhat_Kho values(null,null, N'Sơn sắt','0',50,73000,'lon',null)
insert into Cap_Nhat_Kho values(null,null, N'Sơn gỗ','0',50,42000,'lon',null)
insert into Cap_Nhat_Kho values(null,null, N'Quạt Senko','0',10,240000,'Cây',null)
insert into Cap_Nhat_Kho values(null,null, N'Quạt Asia','0',10,280000,'Cây',null)
insert into Cap_Nhat_Kho values(null,null, N'Quạt Panasonic','0',10,400000,'Cây',null)
insert into Cap_Nhat_Kho values(null,null, N'Quạt Tosiba','0',7,430000,'Cây',null)
insert into Cap_Nhat_Kho values(null,null, N'Xăng thơm','0',100,45000,'lít',null)
insert into Cap_Nhat_Kho values(null,null, N'Lưới thép','0',300,12000,'m',null)
insert into Cap_Nhat_Kho values(null,null, N'Lưới nhựa','0',300,12000,'m',null)
insert into Cap_Nhat_Kho values(null,null, N'Máy nóng lạnh Cento','0',3,2200000,'Cái',null)
insert into Cap_Nhat_Kho values(null,null, N'Máy nóng lạnh Panasonic','0',5,3300000,'Cái',null)
insert into Cap_Nhat_Kho values(null,null, N'Máy nóng lạnh Tosiba','0',2,3700000,'Cái',null)
insert into Cap_Nhat_Kho values(null,null, N'Xe rùa','0',4,330000,'Chiếc',null)
insert into Cap_Nhat_Kho values(null,null, N'Ổ điện','0',50,80000,'Cái',null)
insert into Cap_Nhat_Kho values(null,null, N'Phích cắm','0',50,12000,'Cái',null)
insert into Cap_Nhat_Kho values(null,null, N'Dây điện','0',500,10000,'m',null)
insert into Cap_Nhat_Kho values(null,null, N'Xi măng','0',10,280000,'Bao',null)
insert into Cap_Nhat_Kho values(null,null, N'Dây thép','0',600,20000,'Kg',null)
insert into Cap_Nhat_Kho values(null,null, N'Xẻng','0',15,100000,'Cái',null)
insert into Cap_Nhat_Kho values(null,null, N'Cuốc','0',10,100000,'Cái',null)
go


select * from Cap_Nhat_Kho


create nonclustered index MaHang on Cap_Nhat_Kho(MaHang)

